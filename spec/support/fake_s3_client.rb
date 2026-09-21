# frozen_string_literal: true

# Fake S3 client used in integration tests.
#
# Simulates an isolated in-memory bucket and records the calls made, allowing
# the interaction between the CLI, the storage and the Cloudflare R2 client
# to be validated without depending on a real connection.
class FakeS3Client
    # Response of the object listing operation.
    ObjectList = Struct.new(:contents, :next_continuation_token)

    # Summary of an object stored in the bucket.
    # Listing: https://docs.aws.amazon.com/AmazonS3/latest/API/API_Object.html
    ObjectSummary = Struct.new(:key)

    # Metadata of an object stored in the bucket.
    # Metadata: https://docs.aws.amazon.com/AmazonS3/latest/API/API_HeadObject.html
    ObjectMetadata = Struct.new(:content_length, :content_type, :etag)

    # Error raised when a failure scenario is configured.
    Failure = Class.new(StandardError)

    attr_reader :uploads, :deletes, :downloads, :list_requests, :heads

    # @param objects [Array<String>] keys of the objects already in the bucket
    # @param page_size [Integer, nil] size of each page of the listing, nil for a single page
    def initialize(objects: [], page_size: nil)
        @objects = objects.dup
        @page_size = page_size
        @uploads = []
        @deletes = []
        @downloads = []
        @list_requests = []
        @heads = []
        @failures = {}
        @stored = {}
        @content_types = {}
        objects.each { |key| @stored[key] = "content of #{key}" }
    end

    # Configures a failure scenario for a specific operation.
    #
    # @param operation [Symbol] operation that must fail (:upload, :delete, :list)
    # @param message [String] message of the simulated error
    def fail_on(operation, message: "simulated failure")
        @failures[operation] = message
    end

    # Reads the simulated content stored for the given key.
    #
    # @param key [String] object key
    # @return [String, nil] stored content
    def content_for(key)
        @stored[key]
    end

    # Simulates the creation of an object in the bucket.
    def put_object(bucket:, key:, body:, content_type: nil)
        raise_failure!(:upload)

        content = body.respond_to?(:read) ? body.read : body
        body.rewind if body.respond_to?(:rewind)

        @uploads << { bucket: bucket, key: key, body: body, content_type: content_type }
        @objects << key unless @objects.include?(key)
        @stored[key] = content
        @content_types[key] = content_type

        nil
    end

    # Simulates the deletion of an object from the bucket.
    def delete_object(bucket:, key:)
        raise_failure!(:delete)

        @deletes << { bucket: bucket, key: key }
        @objects.delete(key)
        @stored.delete(key)

        nil
    end

    # Simulates the download of an object from the bucket.
    def get_object(bucket:, key:, response_target:)
        raise_failure!(:download)

        content = @stored[key]
        raise Aws::S3::Errors::NoSuchKey.new(nil, "object does not exist: #{key}") if content.nil?

        @downloads << { bucket: bucket, key: key, response_target: response_target }

        if response_target.respond_to?(:write)
            response_target.write(content)
        else
            File.binwrite(response_target.to_s, content)
        end

        nil
    end

    # Simulates the retrieval of the metadata of an object from the bucket.
    #
    # The retrieval of a missing object is reported through the error raised
    # by Cloudflare R2 for HEAD requests, without a body in the response.
    def head_object(bucket:, key:)
        raise_failure!(:exists)

        content = @stored[key]
        raise Aws::S3::Errors::NotFound.new(nil, "object does not exist: #{key}") if content.nil?

        @heads << { bucket: bucket, key: key }

        ObjectMetadata.new(
            content.bytesize,
            @content_types[key] || "application/octet-stream",
            "etag-#{key}"
        )
    end

    # Simulates the listing of the objects in the bucket.
    #
    # Supports the pagination controls used by the storage layer, so a bucket
    # with more objects than a single page can be reproduced.
    def list_objects_v2(bucket:, prefix: nil, continuation_token: nil)
        raise_failure!(:list)

        record_list_request(bucket, prefix, continuation_token)

        page, next_token = paginate(matching_keys(prefix), continuation_token)

        ObjectList.new(page.map { |key| ObjectSummary.new(key) }, next_token)
    end

    private

    # Records the parameters of a listing request.
    def record_list_request(bucket, prefix, continuation_token)
        @list_requests << { bucket: bucket, prefix: prefix, continuation_token: continuation_token }
    end

    # Keys of the objects that match the given prefix.
    def matching_keys(prefix)
        @objects.select { |key| prefix.nil? || key.start_with?(prefix) }
    end

    # Page of the listing and the token of the following page, if any.
    def paginate(keys, continuation_token)
        offset = continuation_token.to_i
        page = keys[offset, @page_size || keys.size] || []
        next_token = offset + page.size < keys.size ? (offset + page.size).to_s : nil

        [page, next_token]
    end

    # Raises a simulated error when a failure scenario is configured.
    def raise_failure!(operation)
        message = @failures[operation]

        raise Failure, message if message
    end
end
