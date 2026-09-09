# frozen_string_literal: true

require "aws-sdk-s3"
require_relative "errors"
require_relative "logging"

module R2
    # Storage layer responsible for communicating with Cloudflare R2.
    #
    # Uses the `aws-sdk-s3` gem with the S3-compatible endpoint provided by
    # the application configuration.
    class Storage
        # Initializes the storage with the configured credentials and bucket.
        #
        # @param config [Configuration] application configuration
        # @param logger [#debug, nil] logger used for diagnostics
        def initialize(config, logger: nil)
            @bucket = config.bucket
            @logger = logger || R2::Logging::NullLogger.new
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
        # @param key [String] object key in the bucket
        # @param body [IO, String] content of the object to upload
        # @raise [Errors::Error] if the operation fails
        def upload(key:, body:)
            @logger.debug("Uploading object #{key.inspect} to bucket #{@bucket.inspect}.")
            @s3.put_object(
                bucket: @bucket,
                key: key,
                body: body
            )
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
            @s3.delete_object(
                bucket: @bucket,
                key: key
            )
            @logger.debug("Deletion of object #{key.inspect} completed.")
            nil
        rescue StandardError => e
            raise_storage_error(e, operation: "delete", key: key)
        end

        # Lists the objects stored in the configured bucket.
        #
        # @return [Array<String>] keys of the stored objects
        # @raise [Errors::Error] if the operation fails
        def list
            @logger.debug("Listing objects in bucket #{@bucket.inspect}.")
            response = @s3.list_objects_v2(bucket: @bucket)
            keys = response.contents.map(&:key)
            @logger.debug("Found #{keys.size} object(s) in bucket #{@bucket.inspect}.")
            keys
        rescue StandardError => e
            raise_storage_error(e, operation: "list")
        end

        # Downloads an object from the configured bucket.
        #
        # The content is streamed directly to the destination file, so large
        # objects do not need to be fully loaded into memory.
        #
        # @param key [String] object key in the bucket
        # @param destination [String] local path where the content is written
        # @return [String] destination path
        # @raise [Errors::Error] if the operation fails
        def download(key:, destination:)
            @logger.debug("Downloading object #{key.inspect} to #{destination.inspect}.")
            File.open(destination, "wb") do |file|
                @s3.get_object(bucket: @bucket, key: key, response_target: file)
            end
            @logger.debug("Download of object #{key.inspect} completed.")
            destination
        rescue StandardError => e
            raise_storage_error(e, operation: "download", key: key, destination: destination)
        end

        private

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
