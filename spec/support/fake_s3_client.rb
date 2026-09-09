# frozen_string_literal: true

# Fake S3 client used in integration tests.
#
# Simulates an isolated in-memory bucket and records the calls made, allowing
# the interaction between the CLI, the storage and the Cloudflare R2 client
# to be validated without depending on a real connection.
class FakeS3Client
    # Response of the object listing operation.
    ObjectList = Struct.new(:contents)

    # Summary of an object stored in the bucket.
    # Listing: https://docs.aws.amazon.com/AmazonS3/latest/API/API_Object.html
    ObjectSummary = Struct.new(:key)

    # Error raised when a failure scenario is configured.
    Failure = Class.new(StandardError)

    attr_reader :uploads, :deletes, :downloads, :last_list_bucket

    # @param objects [Array<String>] keys of the objects already in the bucket
    def initialize(objects: [])
        @objects = objects.dup
        @uploads = []
        @deletes = []
        @downloads = []
        @failures = {}
        @stored = {}
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
    def put_object(bucket:, key:, body:)
        raise_failure!(:upload)

        content = body.respond_to?(:read) ? body.read : body
        body.rewind if body.respond_to?(:rewind)

        @uploads << { bucket: bucket, key: key, body: body }
        @objects << key unless @objects.include?(key)
        @stored[key] = content

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
        raise Failure, "object does not exist" if content.nil?

        @downloads << { bucket: bucket, key: key, response_target: response_target }

        if response_target.respond_to?(:write)
            response_target.write(content)
        else
            File.binwrite(response_target.to_s, content)
        end

        nil
    end

    # Simulates the listing of the objects in the bucket.
    def list_objects_v2(bucket:)
        raise_failure!(:list)

        @last_list_bucket = bucket
        ObjectList.new(@objects.map { |key| ObjectSummary.new(key) })
    end

    private

    # Raises a simulated error when a failure scenario is configured.
    def raise_failure!(operation)
        message = @failures[operation]

        raise Failure, message if message
    end
end
