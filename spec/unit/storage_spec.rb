# frozen_string_literal: true

require "spec_helper"
require "r2/logging"
require "r2/storage"
require "stringio"

RSpec.describe R2::Storage do
    let(:config) do
        instance_double(
            R2::Configuration,
            bucket: "test-bucket",
            region: "auto",
            access_key_id: "access-key-id",
            secret_access_key: "secret-access-key",
            endpoint: "https://s3.example.com"
        )
    end

    let(:client) { instance_double(Aws::S3::Client) }

    let(:retry_policy) { R2::Retry::Policy.new(max_attempts: 3, base_delay: 0.5) }
    let(:sleeps) { [] }
    let(:sleeper) { ->(seconds) { sleeps << seconds } }
    let(:network_failure) do
        Seahorse::Client::NetworkingError.new(StandardError.new("network failure"))
    end

    subject(:storage) do
        described_class.new(config, retry_policy: retry_policy, sleeper: sleeper)
    end

    before do
        allow(Aws::S3::Client).to receive(:new).and_return(client)
    end

    shared_examples "mapping client failures to domain errors" do
        it "maps credential failures to ConfigurationError" do
            allow(client).to receive(operation).and_raise(Aws::Errors::MissingCredentialsError)

            expect { perform }
                .to raise_error(R2::Errors::ConfigurationError, /credential/)
        end

        it "maps a missing bucket to BucketNotFoundError" do
            allow(client).to receive(operation)
                .and_raise(Aws::S3::Errors::NoSuchBucket.new(nil, "bucket does not exist"))

            expect { perform }
                .to raise_error(R2::Errors::BucketNotFoundError, "Bucket not found: test-bucket")
        end

        it "maps network failures to NetworkError" do
            allow(client).to receive(operation).and_raise(network_failure)

            expect { perform }
                .to raise_error(R2::Errors::NetworkError, "network failure")
        end

        it "retries transient network failures before giving up" do
            attempts = 0
            allow(client).to receive(operation) do
                attempts += 1
                raise network_failure
            end

            expect { perform }.to raise_error(R2::Errors::NetworkError, "network failure")
            expect(attempts).to eq(3)
            expect(sleeps).to eq([0.5, 1.0])
        end

        it "does not retry failures that are not transient" do
            attempts = 0
            allow(client).to receive(operation) do
                attempts += 1
                raise Aws::S3::Errors::NoSuchBucket.new(nil, "bucket does not exist")
            end

            expect { perform }.to raise_error(R2::Errors::BucketNotFoundError)
            expect(attempts).to eq(1)
            expect(sleeps).to be_empty
        end

        it "maps generic failures to StorageError preserving the message" do
            allow(client).to receive(operation).and_raise(StandardError, "network failure")

            expect { perform }
                .to raise_error(R2::Errors::StorageError, "network failure")
        end
    end

    describe "#initialize" do
        it "creates the S3 client with the provided settings" do
            expect(Aws::S3::Client).to receive(:new).with(
                region: "auto",
                access_key_id: "access-key-id",
                secret_access_key: "secret-access-key",
                endpoint: "https://s3.example.com",
                force_path_style: true
            )

            storage
        end

        it "uses the project retry policy when none is given" do
            default = described_class.new(config)

            expect(default.instance_variable_get(:@retry_policy)).to be_a(R2::Retry::Policy)
        end
    end

    describe "#upload" do
        let(:operation) { :put_object }
        let(:perform) { storage.upload(key: "photo.jpg", body: "content") }

        it "sends the content to the bucket with the given key" do
            expect(client).to receive(:put_object).with(
                bucket: "test-bucket",
                key: "photo.jpg",
                body: "content",
                content_type: "image/jpeg"
            )

            perform
        end

        it "determines the content type from the object key" do
            expect(client).to receive(:put_object)
                .with(hash_including(key: "uploads/report.pdf", content_type: "application/pdf"))

            storage.upload(key: "uploads/report.pdf", body: "content")
        end

        it "uses the generic binary type when the extension is unknown" do
            expect(client).to receive(:put_object)
                .with(hash_including(key: "backup", content_type: "application/octet-stream"))

            storage.upload(key: "backup", body: "content")
        end

        it "accepts an explicit content type" do
            expect(client).to receive(:put_object)
                .with(hash_including(key: "notes.txt", content_type: "text/markdown"))

            storage.upload(key: "notes.txt", body: "content", content_type: "text/markdown")
        end

        it "rewinds the streamed content before every attempt" do
            body = StringIO.new("content")
            positions = []
            attempts = 0
            allow(client).to receive(:put_object) do
                positions << body.pos
                attempts += 1
                body.read
                raise network_failure if attempts == 1
            end

            storage.upload(key: "photo.jpg", body: body)

            expect(positions).to eq([0, 0])
        end

        it "writes diagnostics to the injected logger" do
            log_output = StringIO.new
            logged = described_class.new(config, logger: R2::Logging.build(verbose: true, output: log_output))
            allow(client).to receive(:put_object)

            logged.upload(key: "photo.jpg", body: "content")

            expect(log_output.string).to include("photo.jpg")
        end

        it "ignores diagnostics without an injected logger" do
            allow(client).to receive(:put_object)

            expect { storage.upload(key: "photo.jpg", body: "content") }.not_to raise_error
        end

        it_behaves_like "mapping client failures to domain errors"
    end

    describe "#delete" do
        let(:operation) { :delete_object }
        let(:perform) { storage.delete(key: "photo.jpg") }

        it "deletes the object from the bucket" do
            expect(client).to receive(:delete_object).with(
                bucket: "test-bucket",
                key: "photo.jpg"
            )

            perform
        end

        it_behaves_like "mapping client failures to domain errors"
    end

    describe "#download" do
        let(:operation) { :get_object }
        let(:destination) { File.join(TempFileHelper::TEST_TMP_DIR, "retried.jpg") }
        let(:perform) { storage.download(key: "photo.jpg", destination: destination) }

        before { FileUtils.mkdir_p(TempFileHelper::TEST_TMP_DIR) }

        it "streams the object content to the destination file" do
            destination = File.join(TempFileHelper::TEST_TMP_DIR, "photo.jpg")

            expect(client).to receive(:get_object) do |bucket:, key:, response_target:|
                expect(bucket).to eq("test-bucket")
                expect(key).to eq("photo.jpg")
                response_target.write("file content")
            end

            expect(storage.download(key: "photo.jpg", destination: destination)).to eq(destination)
            expect(File.binread(destination)).to eq("file content")
        end

        it "writes the destination from the beginning on every attempt" do
            attempts = 0
            allow(client).to receive(:get_object) do |response_target:, **|
                attempts += 1
                response_target.write("content of attempt #{attempts}")
                raise network_failure if attempts == 1
            end

            storage.download(key: "photo.jpg", destination: destination)

            expect(attempts).to eq(2)
            expect(File.binread(destination)).to eq("content of attempt 2")
        end

        it "maps a missing object to ObjectNotFoundError" do
            allow(client).to receive(operation)
                .and_raise(Aws::S3::Errors::NoSuchKey.new(nil, "object does not exist"))

            expect { perform }
                .to raise_error(R2::Errors::ObjectNotFoundError, "Object not found: photo.jpg")
        end

        it_behaves_like "mapping client failures to domain errors"
    end

    describe "#list" do
        let(:operation) { :list_objects_v2 }
        let(:perform) { storage.list }

        it "returns the keys of the stored objects" do
            response = double(
                "response",
                contents: [
                    double("object-summary", key: "a.jpg"),
                    double("object-summary", key: "b.png")
                ],
                next_continuation_token: nil
            )
            allow(client).to receive(:list_objects_v2).and_return(response)

            expect(storage.list).to eq(%w[a.jpg b.png])
        end

        it "returns an empty list when there are no objects" do
            allow(client).to receive(:list_objects_v2)
                .and_return(double("response", contents: [], next_continuation_token: nil))

            expect(storage.list).to eq([])
        end

        it "follows the pagination until the last page" do
            first_page = double(
                "response",
                contents: [double("object-summary", key: "a.jpg")],
                next_continuation_token: "page-2"
            )
            last_page = double(
                "response",
                contents: [double("object-summary", key: "b.png")],
                next_continuation_token: nil
            )
            allow(client).to receive(:list_objects_v2).and_return(first_page, last_page)

            expect(storage.list).to eq(%w[a.jpg b.png])
        end

        it "requests the next page with the continuation token" do
            expect(client).to receive(:list_objects_v2)
                .with(bucket: "test-bucket")
                .ordered
                .and_return(double("response", contents: [], next_continuation_token: "page-2"))

            expect(client).to receive(:list_objects_v2)
                .with(bucket: "test-bucket", continuation_token: "page-2")
                .ordered
                .and_return(double("response", contents: [], next_continuation_token: nil))

            storage.list
        end

        it "filters the objects by prefix" do
            expect(client).to receive(:list_objects_v2)
                .with(bucket: "test-bucket", prefix: "uploads/")
                .and_return(double("response", contents: [], next_continuation_token: nil))

            expect(storage.list(prefix: "uploads/")).to eq([])
        end

        it_behaves_like "mapping client failures to domain errors"
    end

    describe "#exists?" do
        let(:operation) { :head_object }
        let(:perform) { storage.exists?(key: "photo.jpg") }

        it "returns true when the object exists" do
            expect(client).to receive(:head_object)
                .with(bucket: "test-bucket", key: "photo.jpg")

            expect(perform).to be(true)
        end

        it "returns false when the object does not exist" do
            allow(client).to receive(:head_object)
                .and_raise(Aws::S3::Errors::NotFound.new(nil, "object does not exist"))

            expect(perform).to be(false)
        end

        it "returns false when the object key is reported as missing" do
            allow(client).to receive(:head_object)
                .and_raise(Aws::S3::Errors::NoSuchKey.new(nil, "object does not exist"))

            expect(perform).to be(false)
        end

        it_behaves_like "mapping client failures to domain errors"
    end
end
