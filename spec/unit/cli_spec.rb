# frozen_string_literal: true

require "spec_helper"
require "r2"
require "tmpdir"

RSpec.describe R2::CLI do
    include CliExpectations
    include TempFileHelper

    let(:configuration) { instance_double(R2::Configuration) }
    let(:storage) { instance_double(R2::Storage) }

    subject(:cli) { described_class.new([], configuration: configuration, storage: storage) }

    describe ".exit_on_failure?" do
        it "returns true to exit with a non-zero status code" do
            expect(described_class.exit_on_failure?).to be(true)
        end
    end

    describe ".start" do
        include EnvHelper

        context "when the environment is not configured" do
            it "shows a clear error message and exits with status code 1" do
                with_r2_env({}) do
                    expect { described_class.start(%w[list]) }
                        .to output(
                            /Error: Required environment variable not defined: R2_ACCESS_KEY_ID/
                        ).to_stderr
                        .and raise_error(SystemExit) { |error| expect(error.status).to eq(1) }
                end
            end
        end

        context "when displaying help" do
            it "shows the available commands without requiring environment variables" do
                with_r2_env({}) do
                    expect { described_class.start(%w[--help]) }
                        .to output(/Commands:/).to_stdout
                end
            end
        end
    end

    describe "#upload" do
        let(:file) { create_temp_file(prefix: "upload") }
        let(:key) { File.basename(file) }

        context "on success" do
            it "uploads the file using the file name as the object key" do
                expect(storage).to receive(:upload).with(key: key, body: instance_of(File))

                expect { cli.upload(file) }
                    .to output("Image uploaded successfully: #{key}\n").to_stdout
            end
        end

        context "when the file does not exist" do
            it "shows the error and exits with status code 1" do
                expect(cli).to receive(:warn).with("Error: File not found: missing.jpg")

                expect_cli_to_exit(1) { cli.upload("missing.jpg") }
            end
        end

        context "when the given path is a directory" do
            it "shows the error and exits with status code 1" do
                Dir.mktmpdir do |directory|
                    expect(cli).to receive(:warn)
                        .with("Error: The provided path is not a file: #{directory}")

                    expect_cli_to_exit(1) { cli.upload(directory) }
                end
            end
        end

        context "when the storage fails" do
            it "shows the error and exits with status code 1" do
                allow(storage).to receive(:upload).and_raise(R2::Errors::Error, "invalid bucket")

                expect(cli).to receive(:warn).with("Error: invalid bucket")

                expect_cli_to_exit(1) { cli.upload(file) }
            end
        end
    end

    describe "#delete" do
        context "on success" do
            it "deletes the file from the storage" do
                expect(storage).to receive(:delete).with(key: "photo.jpg")

                expect { cli.delete("photo.jpg") }
                    .to output("File deleted successfully: photo.jpg\n").to_stdout
            end
        end

        context "when the storage fails" do
            it "shows the error and exits with status code 1" do
                allow(storage).to receive(:delete).and_raise(R2::Errors::Error, "invalid bucket")

                expect(cli).to receive(:warn).with("Error: invalid bucket")

                expect_cli_to_exit(1) { cli.delete("photo.jpg") }
            end
        end
    end

    describe "#list" do
        context "when there are objects" do
            it "displays each object on its own line" do
                allow(storage).to receive(:list).and_return(%w[a.jpg b.png])

                expect { cli.list }.to output("a.jpg\nb.png\n").to_stdout
            end
        end

        context "when there are no objects" do
            it "does not display anything" do
                allow(storage).to receive(:list).and_return([])

                expect { cli.list }.not_to output.to_stdout
            end
        end

        context "when the storage fails" do
            it "shows the error and exits with status code 1" do
                allow(storage).to receive(:list).and_raise(R2::Errors::Error, "invalid bucket")

                expect(cli).to receive(:warn).with("Error: invalid bucket")

                expect_cli_to_exit(1) { cli.list }
            end
        end
    end
end
