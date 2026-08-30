# frozen_string_literal: true

require "spec_helper"
require "r2"

RSpec.describe "CLI integrated with the storage", type: :integration do
    include CliRunner
    include TempFileHelper

    let(:client) { FakeS3Client.new }

    before do
        allow(Aws::S3::Client).to receive(:new).and_return(client)
    end

    describe "upload" do
        let(:file) { create_temp_file(prefix: "upload") }
        let(:key) { File.basename(file) }

        context "on success" do
            it "uploads a file to the bucket using the file name as the key" do
                expect { run_cli("upload", file) }
                    .to output("Image uploaded successfully: #{key}\n").to_stdout

                expect(client.uploads.size).to eq(1)
                expect(client.uploads.first[:bucket]).to eq("integration-bucket")
                expect(client.uploads.first[:key]).to eq(key)
                expect(client.uploads.first[:body]).to be_a(File)
            end
        end

        context "when the file does not exist" do
            it "shows the error and exits with status code 1" do
                nonexistent = File.join("tmp", "spec", "missing.jpg")

                run_cli_and_expect_failure(
                    "upload",
                    nonexistent,
                    message: "File not found: #{nonexistent}"
                )
            end
        end

        context "when the storage fails" do
            it "shows the error and exits with status code 1" do
                client.fail_on(:upload)

                run_cli_and_expect_failure("upload", file, message: "simulated failure")

                expect(client.uploads).to be_empty
            end
        end
    end

    describe "list" do
        context "when there are objects" do
            let(:client) { FakeS3Client.new(objects: %w[a.jpg b.png]) }

            it "lists the objects stored in the bucket" do
                expect { run_cli("list") }
                    .to output("a.jpg\nb.png\n").to_stdout
            end
        end

        context "when there are no objects" do
            it "does not display anything" do
                expect { run_cli("list") }.not_to output.to_stdout
            end
        end

        context "when the storage fails" do
            it "shows the error and exits with status code 1" do
                client.fail_on(:list)

                run_cli_and_expect_failure("list", message: "simulated failure")
            end
        end
    end

    describe "delete" do
        context "on success" do
            it "deletes the object from the bucket" do
                expect { run_cli("delete", "photo.jpg") }
                    .to output("File deleted successfully: photo.jpg\n").to_stdout

                expect(client.deletes.size).to eq(1)
                expect(client.deletes.first[:bucket]).to eq("integration-bucket")
                expect(client.deletes.first[:key]).to eq("photo.jpg")
            end
        end

        context "when the storage fails" do
            it "shows the error and exits with status code 1" do
                client.fail_on(:delete)

                run_cli_and_expect_failure("delete", "photo.jpg", message: "simulated failure")
            end
        end
    end

    describe "full cycle" do
        it "performs upload, list and delete together" do
            file = create_temp_file(prefix: "cycle")
            key = File.basename(file)

            expect { run_cli("upload", file) }
                .to output("Image uploaded successfully: #{key}\n").to_stdout

            expect { run_cli("list") }
                .to output(/#{Regexp.escape(key)}/).to_stdout

            expect { run_cli("delete", key) }
                .to output("File deleted successfully: #{key}\n").to_stdout

            expect { run_cli("list") }
                .to output("").to_stdout
        end
    end
end
