# frozen_string_literal: true

module R2
    # Centralization of project errors.
    module Errors
        # Base error of the project.
        #
        # All domain errors inherit from this class, allowing consumers to
        # catch the generic error when they do not need to distinguish the
        # cause, or a specific error when they do.
        class Error < StandardError
        end

        # Required configuration missing or invalid.
        class ConfigurationError < Error
        end

        # The given file does not exist.
        class FileNotFoundError < Error
        end

        # The given path is not a file.
        class InvalidFileError < Error
        end

        # No permission to read the given file.
        class PermissionError < Error
        end

        # The configured bucket does not exist.
        class BucketNotFoundError < Error
        end

        # Network failure while communicating with Cloudflare R2.
        class NetworkError < Error
        end

        # Unclassified failure in the storage layer.
        class StorageError < Error
        end
    end
end
