# Errors

Errors are centralized to standardize their handling and keep the application
behavior consistent.

## Hierarchy

All domain errors inherit from `R2::Errors::Error`:

* `ConfigurationError` — required configuration missing or invalid.
* `FileNotFoundError` — the given file does not exist.
* `InvalidFileError` — the given path is not a file.
* `PermissionError` — no permission to read the given file.
* `BucketNotFoundError` — the configured bucket does not exist.
* `NetworkError` — network failure while communicating with Cloudflare R2.
* `StorageError` — unclassified failure in the storage layer.

## Handling

The specific exceptions of the implementations are converted to the
`R2::Errors` hierarchy, avoiding exposing internal details of the libraries
and allowing consumers to catch the generic error or a specific error.

The CLI catches `R2::Errors::Error`, presents the message on the error output
and exits with a non-zero status code.
