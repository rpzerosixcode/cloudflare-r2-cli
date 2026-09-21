# frozen_string_literal: true

require "aws-sdk-s3"
require_relative "content_type"
require_relative "errors"
require_relative "logging"
require_relative "retry"

module R2
    # Storage layer responsible for communicating with Cloudflare R2.
    #
    # Uses the `aws-sdk-s3` gem with the S3-compatible endpoint provided by
    # the application configuration.
    #
    # Transient network failures are retried with exponential backoff
    # (see `R2::Retry`), so brief instabilities do not fail the operation.
    class Storage
        # Error classes considered transient and therefore retried.
        RETRYABLE_ERRORS = [Seahorse::Client::NetworkingError].freeze

        # Initializes the storage with the configured credentials and bucket.
        #
        # @param config [Configuration] application configuration
        # @param logger [#debug, nil] logger used for diagnostics
        # @param retry_policy [Retry::Policy, nil] retry settings, defaults to the project policy
        # @param sleeper [#call, nil] waiting strategy used between attempts
        def initialize(config, logger: nil, retry_policy: nil, sleeper: nil)
            @bucket = config.bucket
            @logger = logger || R2::Logging::NullLogger.new
            @retry_policy = retry_policy || Retry::Policy.new
            @sleeper = sleeper
            @s3 = Aws::S3::Client.new(
                region: config.region,
                access_key_id: config.access_key_id,
                secret_access_key: config.secret_access_key,
                endpoint: config.endpoint,
                force_path_style: true
            )
        end

        # Uploads an object to the configured bucket.
        #
        # Receives content already prepared by the layer that uses the storage
        # and delivers it to Cloudflare R2.
        #
        # The content type is determined from the object key, unless an
        # explicit value is given, so the stored object is served with the
        # correct type instead of the generic binary type.
        #
        # When the content comes from a stream, it is rewound before every
        # attempt, since a retry must read the content from the beginning.
        #
        # @param key [String] object key in the bucket
        # @param body [IO, String] content of the object to upload
        # @param content_type [String, nil] content type stored in the object metadata
        # @raise [Errors::Error] if the operation fails
        def upload(key:, body:, content_type: nil)
            type = content_type || ContentType.for(key)
            @logger.debug("Uploading object #{key.inspect} as #{type.inspect} to bucket #{@bucket.inspect}.")
            with_retries(operation: "upload", key: key) do
                body.rewind if body.respond_to?(:rewind)
                @s3.put_object(
                    bucket: @bucket,
                    key: key,
                    body: body,
                    content_type: type
                )
            end
            @logger.debug("Upload of object #{key.inspect} completed.")
            nil
        rescue StandardError => e
            raise_storage_error(e, operation: "upload", key: key)
        end

        # Deletes an object from the configured bucket.
        #
        # The operation is considered successful when Cloudflare R2 completes
        # the request without raising an error.
        #
        # @param key [String] object key in the bucket
        # @raise [Errors::Error] if the operation fails
        def delete(key:)
            @logger.debug("Deleting object #{key.inspect} from bucket #{@bucket.inspect}.")
            with_retries(operation: "delete", key: key) do
                @s3.delete_object(
                    bucket: @bucket,
                    key: key
                )
            end
            @logger.debug("Deletion of object #{key.inspect} completed.")
            nil
        rescue StandardError => e
            raise_storage_error(e, operation: "delete", key: key)
        end

        # Lists the objects stored in the configured bucket.
        #
        # Every page of the listing is requested, so all the stored objects
        # are returned regardless of the amount of keys in the bucket.
        #
        # @param prefix [String, nil] lists only the objects whose keys start with the prefix
        # @return [Array<String>] keys of the stored objects
        # @raise [Errors::Error] if the operation fails
        def list(prefix: nil)
            @logger.debug("Listing objects in bucket #{@bucket.inspect} with prefix #{prefix.inspect}.")
            keys = []
            token = nil

            loop do
                response = list_page(token, prefix)
                keys.concat(response.contents.map(&:key))
                token = response.next_continuation_token
                break if token.nil? || token.empty?
            end

            @logger.debug("Found #{keys.size} object(s) in bucket #{@bucket.inspect}.")
            keys
        rescue StandardError => e
            raise_storage_error(e, operation: "list")
        end

        # Downloads an object from the configured bucket.
        #
        # The content is streamed directly to the destination file, so large
        # objects do not need to be fully loaded into memory. Every attempt
        # writes the file from the beginning, avoiding a partially written
        # content when a retry is needed.
        #
        # @param key [String] object key in the bucket
        # @param destination [String] local path where the content is written
        # @return [String] destination path
        # @raise [Errors::Error] if the operation fails
        def download(key:, destination:)
            @logger.debug("Downloading object #{key.inspect} to #{destination.inspect}.")
            with_retries(operation: "download", key: key) do
                File.open(destination, "wb") do |file|
                    @s3.get_object(bucket: @bucket, key: key, response_target: file)
                end
            end
            @logger.debug("Download of object #{key.inspect} completed.")
            destination
        rescue StandardError => e
            raise_storage_error(e, operation: "download", key: key, destination: destination)
        end

        # Checks whether an object exists in the configured bucket.
        #
        # The object metadata is requested instead of the content, so the
        # check is cheap regardless of the object size.
        #
        # @param key [String] object key in the bucket
        # @return [Boolean] true when the object exists
        # @raise [Errors::Error] if the operation fails
        def exists?(key:)
            @logger.debug("Checking whether object #{key.inspect} exists in bucket #{@bucket.inspect}.")
            with_retries(operation: "exists", key: key) do
                @s3.head_object(bucket: @bucket, key: key)
            end
            @logger.debug("Object #{key.inspect} was found in bucket #{@bucket.inspect}.")
            true
        rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
            @logger.debug("Object #{key.inspect} was not found in bucket #{@bucket.inspect}.")
            false
        rescue StandardError => e
            raise_storage_error(e, operation: "exists", key: key)
        end

        private

        # Requests a single page of the object listing.
        #
        # @param token [String, nil] continuation token of the page
        # @param prefix [String, nil] lists only the objects whose keys start with the prefix
        # @return [Object] response of the listing operation
        def list_page(token, prefix)
            params = { bucket: @bucket }
            params[:prefix] = prefix unless prefix.nil?
            params[:continuation_token] = token unless token.nil?

            with_retries(operation: "list") { @s3.list_objects_v2(**params) }
        end

        # Runs the given block retrying transient network failures.
        #
        # @param operation [String] operation being performed
        # @param key [String, nil] object key involved in the operation
        # @yield the request to run against the storage
        # @return [Object] result of the block
        def with_retries(operation:, key: nil, &)
            R2::Retry.call(
                policy: @retry_policy,
                retry_on: RETRYABLE_ERRORS,
                logger: @logger,
                sleeper: @sleeper,
                description: describe_operation(operation, key),
                &
            )
        end

        # Builds the description of an operation used in the diagnostics.
        #
        # @param operation [String] operation being performed
        # @param key [String, nil] object key involved in the operation
        # @return [String] operation description
        def describe_operation(operation, key)
            return "#{operation} on bucket #{@bucket}" if key.nil?

            "#{operation} of #{key}"
        end

        # Converts storage layer errors into project domain errors, avoiding
        # exposing internal details of the implementations.
        #
        # The original message is preserved when useful.
        #
        # @param error [StandardError] original error
        # @param operation [String] operation being performed
        # @param key [String, nil] object key involved in the operation
        # @param destination [String, nil] destination path involved
        # @raise [Errors::Error] subclass matching the cause of the error
        def raise_storage_error(error, operation:, key: nil, destination: nil)
            raise error if error.is_a?(Errors::Error)

            @logger.debug("Operation #{operation} failed: #{error.class}: #{error.message}")

            mapped = map_storage_error(error, key: key, destination: destination)
            raise mapped unless mapped.nil?

            raise Errors::StorageError, error.message
        end

        # Maps known storage failures to domain errors.
        #
        # @param error [StandardError] original error
        # @param key [String, nil] object key involved in the operation
        # @param destination [String, nil] destination path involved
        # @return [Errors::Error, nil] mapped domain error, if recognized
        def map_storage_error(error, key:, destination:)
            case error
            when Aws::Errors::MissingCredentialsError
                Errors::ConfigurationError.new("Missing or invalid credential environment variables.")
            when Aws::S3::Errors::NoSuchBucket
                Errors::BucketNotFoundError.new("Bucket not found: #{@bucket}")
            when Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
                Errors::ObjectNotFoundError.new("Object not found: #{key}")
            when Seahorse::Client::NetworkingError
                Errors::NetworkError.new(error.message)
            when Errno::EACCES, Errno::EPERM
                Errors::PermissionError.new("Permission denied to write the file: #{destination || key}")
            end
        end
    end
end
