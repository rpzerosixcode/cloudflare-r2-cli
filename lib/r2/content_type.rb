# frozen_string_literal: true

module R2
    # Determines the content type of an object from its key.
    #
    # The mapping covers the formats commonly handled by the CLI. Keys whose
    # extension is not mapped fall back to the generic binary type, which is
    # the same behavior offered by S3-compatible services.
    #
    # Reference: https://developer.mozilla.org/docs/Web/HTTP/Basics_of_HTTP/MIME_types
    module ContentType
        # Content type used when the object extension is not mapped.
        DEFAULT = "application/octet-stream"

        # Content types by file extension.
        TYPES = {
            ".avif" => "image/avif",
            ".bmp" => "image/bmp",
            ".csv" => "text/csv",
            ".doc" => "application/msword",
            ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            ".gif" => "image/gif",
            ".gz" => "application/gzip",
            ".htm" => "text/html",
            ".html" => "text/html",
            ".ico" => "image/vnd.microsoft.icon",
            ".jpeg" => "image/jpeg",
            ".jpg" => "image/jpeg",
            ".js" => "text/javascript",
            ".json" => "application/json",
            ".md" => "text/markdown",
            ".mp3" => "audio/mpeg",
            ".mp4" => "video/mp4",
            ".pdf" => "application/pdf",
            ".png" => "image/png",
            ".svg" => "image/svg+xml",
            ".tar" => "application/x-tar",
            ".tif" => "image/tiff",
            ".tiff" => "image/tiff",
            ".txt" => "text/plain",
            ".wav" => "audio/wav",
            ".webp" => "image/webp",
            ".xls" => "application/vnd.ms-excel",
            ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            ".xml" => "application/xml",
            ".yaml" => "application/yaml",
            ".yml" => "application/yaml",
            ".zip" => "application/zip"
        }.freeze

        # Determines the content type of the given object key.
        #
        # The extension is compared in lowercase, so keys stored with
        # uppercase names are also recognized.
        #
        # @param key [String] object key in the bucket
        # @return [String] content type corresponding to the key extension
        def self.for(key)
            TYPES.fetch(extension(key), DEFAULT)
        end

        # Extracts the extension of the given object key.
        #
        # @param key [String] object key in the bucket
        # @return [String] lowercase extension, including the leading dot
        def self.extension(key)
            File.extname(key.to_s).downcase
        end
    end
end
