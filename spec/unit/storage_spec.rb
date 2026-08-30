# frozen_string_literal: true

require "spec_helper"
require "r2/storage"

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

    subject(:storage) { described_class.new(config) }

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
            allow(client).to receive(operation)
                .and_raise(Seahorse::Client::NetworkingError.new(StandardError.new("network failure")))

            expect { perform }
                .to raise_error(R2::Errors::NetworkError, "network failure")
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
    end

    describe "#upload" do
        let(:operation) { :put_object }
        let(:perform) { storage.upload(key: "photo.jpg", body: "content") }

        it "sends the content to the bucket with the given key" do
            expect(client).to receive(:put_object).with(
                bucket: "test-bucket",
                key: "photo.jpg",
                body: "content"
            )

            perform
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

    describe "#list" do
        let(:operation) { :list_objects_v2 }
        let(:perform) { storage.list }

        it "returns the keys of the stored objects" do
            response = double(
                "response",
                contents: [
                    double("object-summary", key: "a.jpg"),
                    double("object-summary", key: "b.png")
                ]
            )
            allow(client).to receive(:list_objects_v2).and_return(response)

            expect(storage.list).to eq(%w[a.jpg b.png])
        end

        it "returns an empty list when there are no objects" do
            allow(client).to receive(:list_objects_v2).and_return(double("response", contents: []))

            expect(storage.list).to eq([])
        end

        it_behaves_like "mapping client failures to domain errors"
    end
end
