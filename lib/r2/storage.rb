# frozen_string_literal: true

require "aws-sdk-s3"
require_relative "errors"

module R2
    # Storage layer responsible for communicating with Cloudflare R2.
    #
    # Uses the `aws-sdk-s3` gem with the S3-compatible endpoint provided by
    # the application configuration.
    class Storage
        # Initializes the storage with the configured credentials and bucket.
        #
        # @param config [Configuration] application configuration
        def initialize(config)
            @bucket = config.bucket
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
            @s3.put_object(
                bucket: @bucket,
                key: key,
                body: body
            )
        rescue StandardError => e
            raise_storage_error(e)
        end

        # Deletes an object from the configured bucket.
        #
        # The operation is considered successful when Cloudflare R2 completes
        # the request without raising an error.
        #
        # @param key [String] object key in the bucket
        # @raise [Errors::Error] if the operation fails
        def delete(key:)
            @s3.delete_object(
                bucket: @bucket,
                key: key
            )
        rescue StandardError => e
            raise_storage_error(e)
        end

        # Lists the objects stored in the configured bucket.
        #
        # @return [Array<String>] keys of the stored objects
        # @raise [Errors::Error] if the operation fails
        def list
            response = @s3.list_objects_v2(bucket: @bucket)
            response.contents.map(&:key)
        rescue StandardError => e
            raise_storage_error(e)
        end

        private

        # Converts storage layer errors into project domain errors, avoiding
        # exposing internal details of the implementations.
        #
        # The original message is preserved when useful.
        #
        # @param error [StandardError] original error
        # @raise [Errors::Error] subclass matching the cause of the error
        def raise_storage_error(error)
            case error
            when Aws::Errors::MissingCredentialsError
                raise Errors::ConfigurationError,
                      "Missing or invalid credential environment variables."
            when Aws::S3::Errors::NoSuchBucket
                raise Errors::BucketNotFoundError, "Bucket not found: #{@bucket}"
            when Seahorse::Client::NetworkingError
                raise Errors::NetworkError, error.message
            else
                raise Errors::StorageError, error.message
            end
        end
    end
end
