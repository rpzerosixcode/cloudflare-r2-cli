# frozen_string_literal: true

require "spec_helper"
require "r2"

RSpec.describe "CLI integrated with the storage", type: :integration do
    include CliRunner
    include StdinHelper
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
                    .to output("Uploaded successfully: #{key}\n").to_stdout

                expect(client.uploads.size).to eq(1)
                expect(client.uploads.first[:bucket]).to eq("integration-bucket")
                expect(client.uploads.first[:key]).to eq(key)
                expect(client.uploads.first[:body]).to be_a(File)
            end

            it "uploads a file using a custom key when --key is given" do
                expect { run_cli("upload", file, "--key", "uploads/custom.jpg") }
                    .to output("Uploaded successfully: uploads/custom.jpg\n").to_stdout

                expect(client.uploads.first[:key]).to eq("uploads/custom.jpg")
                expect(client.content_for("uploads/custom.jpg")).not_to be_nil
            end

            it "defines the content type from the object key" do
                stdout, = capture_cli_streams("upload", file)

                expect(stdout).to eq("Uploaded successfully: #{key}\n")
                expect(client.uploads.first[:content_type]).to eq("image/jpeg")
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

        context "when the bucket has more objects than a single page" do
            let(:client) { FakeS3Client.new(objects: %w[a.jpg b.png c.txt d.pdf e.json], page_size: 2) }

            it "follows the pagination until the last page" do
                expect { run_cli("list") }
                    .to output("a.jpg\nb.png\nc.txt\nd.pdf\ne.json\n").to_stdout

                expect(client.list_requests.size).to eq(3)
                expect(client.list_requests.first).to include(bucket: "integration-bucket", prefix: nil)
                expect(client.list_requests.last[:continuation_token]).to eq("4")
            end
        end

        context "with --prefix" do
            let(:client) { FakeS3Client.new(objects: %w[uploads/a.jpg uploads/b.png other.jpg]) }

            it "lists only the objects whose keys start with the prefix" do
                expect { run_cli("list", "--prefix", "uploads/") }
                    .to output("uploads/a.jpg\nuploads/b.png\n").to_stdout

                expect(client.list_requests.first[:prefix]).to eq("uploads/")
            end

            it "does not display anything when no object matches the prefix" do
                expect { run_cli("list", "--prefix", "missing/") }.not_to output.to_stdout
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

    describe "download" do
        let(:client) { FakeS3Client.new(objects: %w[photo.jpg]) }

        context "on success" do
            it "downloads the object to a file with the key base name" do
                Dir.mktmpdir do |directory|
                    Dir.chdir(directory) do
                        expect { run_cli("download", "photo.jpg") }
                            .to output("Downloaded successfully: photo.jpg\n").to_stdout

                        expect(File.binread("photo.jpg")).to eq("content of photo.jpg")
                        expect(client.downloads.size).to eq(1)
                        expect(client.downloads.first[:bucket]).to eq("integration-bucket")
                        expect(client.downloads.first[:key]).to eq("photo.jpg")
                    end
                end
            end

            it "downloads the object to a custom destination when --output is given" do
                destination = File.join(TempFileHelper::TEST_TMP_DIR, "custom.jpg")
                FileUtils.mkdir_p(TempFileHelper::TEST_TMP_DIR)

                expect { run_cli("download", "photo.jpg", "--output", destination) }
                    .to output("Downloaded successfully: #{destination}\n").to_stdout

                expect(File.binread(destination)).to eq("content of photo.jpg")
            end
        end

        context "when the object does not exist" do
            it "shows the error and exits with status code 1" do
                Dir.mktmpdir do |directory|
                    Dir.chdir(directory) do
                        run_cli_and_expect_failure(
                            "download",
                            "missing.jpg",
                            message: "Object not found: missing.jpg"
                        )
                    end
                end
            end
        end

        context "when the storage fails" do
            it "shows the error and exits with status code 1" do
                client.fail_on(:download)

                Dir.mktmpdir do |directory|
                    Dir.chdir(directory) do
                        run_cli_and_expect_failure("download", "photo.jpg", message: "simulated failure")
                    end
                end
            end
        end

        context "with --verbose" do
            it "writes detailed information to the error output" do
                Dir.mktmpdir do |directory|
                    Dir.chdir(directory) do
                        _stdout, stderr = capture_cli_streams("download", "photo.jpg", "--verbose")

                        expect(stderr).to include("Starting download")
                    end
                end
            end
        end
    end

    describe "delete" do
        context "on success" do
            it "deletes the object from the bucket with --force" do
                expect { run_cli("delete", "photo.jpg", "--force") }
                    .to output("Deleted successfully: photo.jpg\n").to_stdout

                expect(client.deletes.size).to eq(1)
                expect(client.deletes.first[:bucket]).to eq("integration-bucket")
                expect(client.deletes.first[:key]).to eq("photo.jpg")
            end
        end

        context "with an interactive confirmation" do
            it "deletes the object when the user confirms" do
                with_fake_stdin("y\n") do
                    stdout, = capture_cli_streams("delete", "photo.jpg")

                    expect(stdout).to eq(
                        %(Delete "photo.jpg" from the bucket? [y/N] Deleted successfully: photo.jpg\n)
                    )
                end

                expect(client.deletes.first[:key]).to eq("photo.jpg")
            end

            it "cancels the deletion when the user declines" do
                allow(client).to receive(:delete_object)

                with_fake_stdin("n\n") do
                    expect { expect_cli_to_exit(1) { run_cli("delete", "photo.jpg") } }
                        .to output(%(Delete "photo.jpg" from the bucket? [y/N] )).to_stdout
                        .and output(/Error: Deletion aborted: photo.jpg/).to_stderr
                end

                expect(client).not_to have_received(:delete_object)
            end
        end

        context "without an interactive input" do
            it "requires --force and exits with status code 1" do
                allow(client).to receive(:delete_object)

                with_fake_stdin(interactive: false) do
                    run_cli_and_expect_failure(
                        "delete",
                        "photo.jpg",
                        message: "Deletion of photo.jpg requires confirmation"
                    )
                end

                expect(client).not_to have_received(:delete_object)
            end
        end

        context "when the storage fails" do
            it "shows the error and exits with status code 1" do
                client.fail_on(:delete)

                run_cli_and_expect_failure("delete", "photo.jpg", "--force", message: "simulated failure")
            end
        end
    end

    describe "exists" do
        context "when the object exists" do
            let(:client) { FakeS3Client.new(objects: %w[photo.jpg]) }

            it "reports that the object exists" do
                expect { run_cli("exists", "photo.jpg") }
                    .to output("Object exists: photo.jpg\n").to_stdout

                expect(client.heads.first[:key]).to eq("photo.jpg")
            end

            it "reports that an uploaded object exists" do
                file = create_temp_file(prefix: "exists")
                key = File.basename(file)

                capture_cli_streams("upload", file)

                expect { run_cli("exists", key) }
                    .to output("Object exists: #{key}\n").to_stdout
            end
        end

        context "when the object does not exist" do
            it "reports that the object was not found and exits with status code 1" do
                expect { expect_cli_to_exit(1) { run_cli("exists", "missing.jpg") } }
                    .to output("Object not found: missing.jpg\n").to_stdout
            end
        end

        context "when the storage fails" do
            it "shows the error and exits with status code 1" do
                client.fail_on(:exists)

                run_cli_and_expect_failure("exists", "photo.jpg", message: "simulated failure")
            end
        end
    end

    describe "full cycle" do
        it "performs upload, exists, download, list and delete together" do
            file = create_temp_file(prefix: "cycle")
            key = File.basename(file)

            expect { run_cli("upload", file) }
                .to output("Uploaded successfully: #{key}\n").to_stdout

            expect { run_cli("list") }
                .to output(/#{Regexp.escape(key)}/).to_stdout

            Dir.mktmpdir do |directory|
                Dir.chdir(directory) do
                    expect { run_cli("download", key) }
                        .to output("Downloaded successfully: #{key}\n").to_stdout

                    expect(File.exist?(key)).to be(true)
                end
            end

            expect { run_cli("exists", key) }
                .to output("Object exists: #{key}\n").to_stdout

            expect { run_cli("delete", key, "--force") }
                .to output("Deleted successfully: #{key}\n").to_stdout

            expect { expect_cli_to_exit(1) { run_cli("exists", key) } }
                .to output("Object not found: #{key}\n").to_stdout

            expect { run_cli("list") }
                .to output("").to_stdout
        end
    end
end
