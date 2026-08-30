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

    attr_reader :uploads, :deletes, :last_list_bucket

    # @param objects [Array<String>] keys of the objects already in the bucket
    def initialize(objects: [])
        @objects = objects.dup
        @uploads = []
        @deletes = []
        @failures = {}
    end

    # Configures a failure scenario for a specific operation.
    #
    # @param operation [Symbol] operation that must fail (:upload, :delete, :list)
    # @param message [String] message of the simulated error
    def fail_on(operation, message: "simulated failure")
        @failures[operation] = message
    end

    # Simulates the creation of an object in the bucket.
    def put_object(bucket:, key:, body:)
        raise_failure!(:upload)

        @uploads << { bucket: bucket, key: key, body: body }
        @objects << key

        nil
    end

    # Simulates the deletion of an object from the bucket.
    def delete_object(bucket:, key:)
        raise_failure!(:delete)

        @deletes << { bucket: bucket, key: key }
        @objects.delete(key)

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
