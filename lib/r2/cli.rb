# frozen_string_literal: true

require "thor"
require_relative "errors"

module R2
    # Command line interface of the project.
    #
    # Acts as a minimal orchestrator: interprets the user's input, delegates
    # the execution to the responsible components and presents the results.
    class CLI < Thor
        # Initializes the CLI with its dependencies.
        #
        # Dependencies are loaded lazily: they are only created when the first
        # command actually uses them. This allows help and command listing to
        # work without a configured environment.
        #
        # @param configuration [Configuration] application configuration
        # @param storage [Storage] storage used in object operations
        def initialize(
            *,
            configuration: nil,
            storage: nil
        )
            super(*)
            @configuration = configuration
            @storage = storage
        end

        # Ensures that Thor exits with a non-zero status code when an
        # operation fails.
        def self.exit_on_failure?
            true
        end

        # Starts the CLI and clearly presents domain errors not handled by
        # the commands.
        #
        # Errors raised before a command runs (such as missing configuration)
        # are caught here, shown on the error output and terminate the CLI
        # with status code 1, avoiding stack traces.
        def self.start(*args)
            super
        rescue Errors::Error => e
            warn "Error: #{e.message}"
            exit 1
        end

        desc "upload FILE", "Uploads an image to R2"

        long_desc <<~LONGDESC
            Uploads an image to the configured Cloudflare R2 bucket.
            The object key in the bucket will be the name of the given file.

            Examples:

              $ r2 upload image.jpg

              $ r2 upload ./images/photo.png
        LONGDESC

        # Uploads an image to the configured Cloudflare R2 bucket.
        #
        # The object key in the bucket will be the name of the given file.
        #
        # @param file [String] path of the file to upload
        def upload(file)
            body = open_file(file)
            storage.upload(key: File.basename(file), body: body)
            puts "Image uploaded successfully: #{File.basename(file)}"
        rescue Errors::Error => e
            warn "Error: #{e.message}"
            exit 1
        ensure
            body&.close
        end

        desc "delete FILE", "Deletes a file from R2"

        long_desc <<~LONGDESC
            Deletes a file from the configured Cloudflare R2 bucket.

            Examples:

              $ r2 delete image.jpg
        LONGDESC

        # Deletes a file from the configured Cloudflare R2 bucket.
        #
        # The operation is considered successful when the storage completes
        # the request without errors.
        #
        # @param file [String] name of the file to delete
        def delete(file)
            storage.delete(key: file)
            puts "File deleted successfully: #{file}"
        rescue Errors::Error => e
            warn "Error: #{e.message}"
            exit 1
        end

        desc "list", "Lists the files stored in R2"

        long_desc <<~LONGDESC
            Lists the files stored in the configured Cloudflare R2 bucket.

            Examples:

              $ r2 list
        LONGDESC

        # Lists the files stored in the configured Cloudflare R2 bucket.
        def list
            files = storage.list

            files.each do |file|
                puts file
            end
        rescue Errors::Error => e
            warn "Error: #{e.message}"
            exit 1
        end

        private

        # Opens the given file for reading.
        #
        # The file must remain open during the upload, so the block form is
        # not used; closing is guaranteed in the `ensure` of the `upload`
        # command.
        #
        # @param file [String] file path
        # @return [File] file opened in binary read mode
        # @raise [Errors::FileNotFoundError] if the file does not exist
        # @raise [Errors::InvalidFileError] if the path is not a file
        # @raise [Errors::PermissionError] if the file cannot be read
        def open_file(file)
            raise Errors::FileNotFoundError, "File not found: #{file}" unless File.exist?(file)
            raise Errors::InvalidFileError, "The provided path is not a file: #{file}" unless File.file?(file)
            raise Errors::PermissionError, "Permission denied to read the file: #{file}" unless File.readable?(file)

            File.open(file, "rb")
        rescue Errno::EACCES, Errno::EPERM
            raise Errors::PermissionError, "Permission denied to read the file: #{file}"
        end

        # Returns the application configuration, creating it lazily on first use.
        #
        # @return [Configuration] application configuration
        def configuration
            @configuration ||= Configuration.new
        end

        # Returns the storage, creating it lazily on first use.
        #
        # @return [Storage] storage used in object operations
        def storage
            @storage ||= Storage.new(configuration)
        end
    end
end
