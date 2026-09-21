# frozen_string_literal: true

require "thor"
require_relative "errors"
require_relative "logging"

module R2
    # Command line interface of the project.
    #
    # Acts as a minimal orchestrator: interprets the user's input, delegates
    # the execution to the responsible components and presents the results.
    class CLI < Thor
        class_option :verbose,
                     type: :boolean,
                     default: false,
                     desc: "Displays detailed information during execution"

        # Initializes the CLI with its dependencies.
        #
        # Dependencies are loaded lazily: they are only created when the first
        # command actually uses them. This allows help and command listing to
        # work without a configured environment.
        #
        # @param configuration [Configuration] application configuration
        # @param storage [Storage] storage used in object operations
        # @param logger [#debug, nil] logger used for diagnostics
        def initialize(
            *,
            configuration: nil,
            storage: nil,
            logger: nil
        )
            super(*)
            @configuration = configuration
            @storage = storage
            @injected_logger = logger
            @logger = nil
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

        desc "upload FILE", "Uploads a file to R2"
        method_option :key,
                      type: :string,
                      desc: "Custom object key used in the bucket"

        long_desc <<~LONGDESC
            Uploads a file to the configured Cloudflare R2 bucket.
            By default, the object key is the name of the given file.
            Use --key to store the object under a custom key.

            Examples:

              $ r2 upload image.jpg

              $ r2 upload ./images/photo.png --key uploads/photo.png
        LONGDESC

        # Uploads a file to the configured Cloudflare R2 bucket.
        #
        # @param file [String] path of the file to upload
        def upload(file)
            key = options[:key] || File.basename(file)
            logger.debug("Starting upload: #{file.inspect} as #{key.inspect}.")
            body = open_file(file)
            storage.upload(key: key, body: body)
            puts "Uploaded successfully: #{key}"
            logger.debug("Finished upload: #{key.inspect}.")
        rescue Errors::Error => e
            warn "Error: #{e.message}"
            exit 1
        ensure
            body&.close
        end

        desc "download KEY", "Downloads a file from R2"
        method_option :output,
                      type: :string,
                      desc: "Local path where the content is written"

        long_desc <<~LONGDESC
            Downloads a file from the configured Cloudflare R2 bucket.
            By default, the content is written to a file with the object
            key base name in the current directory.
            Use --output to choose a custom destination path.

            Examples:

              $ r2 download image.jpg

              $ r2 download image.jpg --output ./images/photo.png
        LONGDESC

        # Downloads a file from the configured Cloudflare R2 bucket.
        #
        # @param key [String] object key in the bucket
        def download(key)
            destination = options[:output] || File.basename(key)
            logger.debug("Starting download: #{key.inspect} to #{destination.inspect}.")
            ensure_destination_writable(destination)
            storage.download(key: key, destination: destination)
            puts "Downloaded successfully: #{destination}"
            logger.debug("Finished download: #{key.inspect}.")
        rescue Errors::Error => e
            warn "Error: #{e.message}"
            exit 1
        end

        desc "delete FILE", "Deletes a file from R2"
        method_option :force,
                      type: :boolean,
                      default: false,
                      desc: "Deletes without asking for confirmation"

        long_desc <<~LONGDESC
            Deletes a file from the configured Cloudflare R2 bucket.

            The deletion is confirmed before the request is sent. Since a
            non-interactive execution cannot ask the user, it requires the
            --force option to proceed.

            Examples:

              $ r2 delete image.jpg

              $ r2 delete image.jpg --force
        LONGDESC

        # Deletes a file from the configured Cloudflare R2 bucket.
        #
        # The operation is considered successful when the storage completes
        # the request without errors.
        #
        # @param file [String] name of the file to delete
        def delete(file)
            logger.debug("Starting delete: #{file.inspect}.")
            confirm_deletion(file)
            storage.delete(key: file)
            puts "Deleted successfully: #{file}"
            logger.debug("Finished delete: #{file.inspect}.")
        rescue Errors::Error => e
            warn "Error: #{e.message}"
            exit 1
        end

        desc "list", "Lists the files stored in R2"
        method_option :prefix,
                      type: :string,
                      desc: "Lists only the objects whose keys start with the given prefix"

        long_desc <<~LONGDESC
            Lists the files stored in the configured Cloudflare R2 bucket.

            Every object is listed, following the pagination of the bucket.
            Use --prefix to list only the objects whose keys start with the
            given prefix.

            Examples:

              $ r2 list

              $ r2 list --prefix uploads/
        LONGDESC

        # Lists the files stored in the configured Cloudflare R2 bucket.
        def list
            logger.debug("Starting list: prefix=#{options[:prefix].inspect}.")
            files = storage.list(prefix: options[:prefix])

            files.each do |file|
                puts file
            end
            logger.debug("Finished list: #{files.size} object(s).")
        rescue Errors::Error => e
            warn "Error: #{e.message}"
            exit 1
        end

        desc "exists KEY", "Checks whether an object exists in R2"

        long_desc <<~LONGDESC
            Checks whether an object exists in the configured Cloudflare R2
            bucket. The exit status is 0 when the object exists and 1 when it
            does not, which allows the command to be used in scripts.

            Examples:

              $ r2 exists image.jpg
        LONGDESC

        # Checks whether an object exists in the configured Cloudflare R2
        # bucket.
        #
        # @param key [String] object key in the bucket
        def exists(key)
            logger.debug("Starting existence check: #{key.inspect}.")

            if storage.exists?(key: key)
                puts "Object exists: #{key}"
                logger.debug("Finished existence check: #{key.inspect} exists.")
            else
                puts "Object not found: #{key}"
                logger.debug("Finished existence check: #{key.inspect} does not exist.")
                exit 1
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
        # Shares the CLI logger with the storage so diagnostics follow
        # the requested verbosity.
        #
        # @return [Storage] storage used in object operations
        def storage
            @storage ||= Storage.new(configuration, logger: logger)
        end

        # Returns the logger used for diagnostics.
        #
        # An injected logger is always used as-is. Otherwise, a logger is
        # built from the `--verbose` flag: verbose output goes to the
        # error output, while the default is a null logger that silently
        # ignores debug messages.
        #
        # @return [#debug] logger used for diagnostics
        def logger
            return @logger if logger_ready?

            @logger_verbose = verbose?
            @logger = build_logger
        end

        # Indicates whether verbose output was requested.
        #
        # @return [Boolean] true when `--verbose` was given
        def verbose?
            options[:verbose] == true
        end

        # Indicates whether the logger already matches the current verbosity.
        #
        # @return [Boolean] true when the logger is ready to use
        def logger_ready?
            !@logger.nil? && defined?(@logger_verbose) && @logger_verbose == verbose?
        end

        # Builds the logger for the current verbosity.
        #
        # @return [#debug] logger used for diagnostics
        def build_logger
            return @injected_logger unless @injected_logger.nil?

            R2::Logging.build(verbose: verbose?)
        end

        # Ensures the download destination can be written.
        #
        # @param destination [String] local path where the content is written
        # @raise [Errors::InvalidFileError] if the destination is a directory
        # @raise [Errors::PermissionError] if the destination cannot be written
        def ensure_destination_writable(destination)
            if File.directory?(destination)
                raise Errors::InvalidFileError, "The destination path is a directory: #{destination}"
            end

            parent = File.dirname(destination)

            raise Errors::FileNotFoundError, "Destination directory not found: #{parent}" unless File.directory?(parent)

            return if File.writable?(parent) && (!File.exist?(destination) || File.writable?(destination))

            raise Errors::PermissionError, "Permission denied to write the file: #{destination}"
        end

        # Asks the user to confirm the deletion of an object.
        #
        # The confirmation is skipped when `--force` is given. Without it the
        # deletion only happens after an affirmative answer, which requires an
        # interactive input: scripts and pipelines cannot be asked, so they
        # must opt out explicitly, avoiding accidental deletions.
        #
        # @param key [String] object key in the bucket
        # @raise [Errors::ConfirmationRequiredError] when the input is not
        #   interactive and `--force` was not given
        # @raise [Errors::AbortedError] when the deletion is not confirmed
        def confirm_deletion(key)
            if options[:force]
                logger.debug("Skipping the deletion confirmation: --force was given.")
                return
            end

            raise Errors::ConfirmationRequiredError, confirmation_required_message(key) unless interactive_input?

            return if affirmative?(ask_deletion_confirmation(key))

            raise Errors::AbortedError, "Deletion aborted: #{key}"
        end

        # Writes the deletion confirmation prompt and reads the answer.
        #
        # @param key [String] object key in the bucket
        # @return [String, nil] answer given by the user
        def ask_deletion_confirmation(key)
            $stdout.print("Delete #{key.inspect} from the bucket? [y/N] ")
            $stdin.gets
        end

        # Indicates whether the standard input can be used to ask the user.
        #
        # @return [Boolean] true when the input is a terminal
        def interactive_input?
            $stdin.respond_to?(:tty?) && $stdin.tty?
        end

        # Indicates whether the given answer confirms the operation.
        #
        # @param answer [String, nil] answer given by the user
        # @return [Boolean] true when the answer is affirmative
        def affirmative?(answer)
            answer.to_s.strip.match?(/\Ay(es)?\z/i)
        end

        # Builds the message shown when the confirmation cannot be requested.
        #
        # @param key [String] object key in the bucket
        # @return [String] message explaining how to proceed
        def confirmation_required_message(key)
            "Deletion of #{key} requires confirmation. Run the command in an " \
                "interactive terminal or use --force to delete it without confirmation."
        end
    end
end
