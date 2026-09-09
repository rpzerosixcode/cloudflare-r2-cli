# frozen_string_literal: true

RSpec.describe "R2 CLI", type: :e2e do
    include E2EHelper

    after do
        cleanup_temp_files!
        cleanup_external_data!
    end

    describe "upload" do
        it "uploads a file to the test bucket" do
            file = create_temp_file
            key = File.basename(file)

            stdout, stderr, status = run_cli("upload", file)

            expect(status).to be_success
            expect(stderr).to be_empty
            expect(stdout).to include("Uploaded successfully: #{key}")
        end

        it "uploads a file using a custom key" do
            file = create_temp_file
            custom_key = "e2e/#{File.basename(file)}"

            stdout, stderr, status = run_cli("upload", file, "--key", custom_key)

            expect(status).to be_success
            expect(stderr).to be_empty
            expect(stdout).to include("Uploaded successfully: #{custom_key}")

            tracked_keys << custom_key
        end
    end

    describe "download" do
        it "downloads an object stored in the bucket" do
            file = create_temp_file
            key = File.basename(file)

            run_cli("upload", file)

            Dir.mktmpdir do |directory|
                destination = File.join(directory, "downloaded-#{key}")

                stdout, stderr, status = run_cli("download", key, "--output", destination)

                expect(status).to be_success
                expect(stderr).to be_empty
                expect(stdout).to include("Downloaded successfully: #{destination}")
                expect(File.exist?(destination)).to be(true)
                expect(File.size(destination)).to be > 0
            end
        end
    end

    describe "list" do
        it "lists the objects stored in the bucket" do
            file = create_temp_file
            key = File.basename(file)

            run_cli("upload", file)

            stdout, stderr, status = run_cli("list")

            expect(status).to be_success
            expect(stderr).to be_empty
            expect(stdout).to include(key)
        end
    end

    describe "delete" do
        it "removes an object stored in the bucket" do
            file = create_temp_file
            key = File.basename(file)

            run_cli("upload", file)

            stdout, stderr, status = run_cli("delete", key)

            expect(status).to be_success
            expect(stderr).to be_empty
            expect(stdout).to include("Deleted successfully: #{key}")
        end
    end

    describe "--verbose" do
        it "writes detailed information to the error output" do
            file = create_temp_file

            run_cli("upload", file)

            _stdout, stderr, status = run_cli("list", "--verbose")

            expect(status).to be_success
            expect(stderr).not_to be_empty
        end
    end
end
