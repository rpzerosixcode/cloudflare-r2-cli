# Architecture

## Layers

### CLI

`lib/r2/cli.rb`

Built with `thor`. Acts as a minimal orchestrator:

* Parses command-line input.
* Delegates operations to `Storage` and `Configuration`.
* Prints results to the user.
* Handles domain errors.

The CLI contains no business rules and does not access files or `ENV` directly.

Commands that delete data ask for confirmation before delegating the operation. The confirmation is requested only when the standard input is a terminal, and `--force` skips it, so non-interactive executions must opt out explicitly.

### Configuration

`lib/r2/configuration.rb`

Responsible exclusively for application configuration:

* Reads settings from environment variables.
* Requires `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_ENDPOINT`, and `R2_BUCKET`.
* Defaults `R2_REGION` to `auto`.
* Raises `Errors::ConfigurationError` when a required variable is missing.

No other component reads `ENV` directly.

### Storage

`lib/r2/storage.rb`

Wraps `aws-sdk-s3` to communicate with the S3-compatible Cloudflare R2 endpoint.

Responsible only for:

* Uploading objects, defining the content type from the object key.
* Downloading objects.
* Deleting objects.
* Listing objects, following the pagination of the bucket and filtering by prefix.
* Checking whether an object exists.

`Storage` does not:

* Read local files.
* Transform content.
* Determine object keys.
* Read configuration directly from `ENV`.

The bucket is provided by `Configuration` rather than passed to individual operations.

Every request is wrapped in the retry support (see `Retry`), so transient network failures are retried before the failure reaches the caller.

### Content Type

`lib/r2/content_type.rb`

Defines the content type of an object from the extension of its key:

* `ContentType.for(key)` returns the mapped type, or `application/octet-stream` when the extension is not mapped.
* The comparison is case insensitive, and keys inside directories are supported.

`Storage#upload` uses this value automatically and accepts an explicit `content_type` when the caller needs to override it.

### Retry

`lib/r2/retry.rb`

Concentrates the automatic retries of the application:

* `Policy` holds the retry settings: total attempts, base delay and maximum delay.
* `Retry.call` runs the block and retries only the error classes informed as transient, waiting between the attempts with exponential backoff.
* The waiting strategy and the logger are injected, keeping the behavior testable without real waiting.

`Storage` uses a shared policy for every operation and passes `Seahorse::Client::NetworkingError` as the transient error, which is also the error mapped to `NetworkError`.

### Errors

`lib/r2/errors.rb`

Defines the application's domain-level errors.

All errors inherit from `R2::Errors::Error`. Exceptions raised by `aws-sdk-s3` are mapped to specific application errors:

* `ConfigurationError`
* `BucketNotFoundError`
* `ObjectNotFoundError`
* `NetworkError`
* `StorageError`

Errors of the CLI are also part of the domain:

* `ConfirmationRequiredError` when a destructive operation cannot be confirmed in a non-interactive execution.
* `AbortedError` when the user does not confirm a destructive operation.

This prevents callers from depending on AWS SDK-specific exceptions.

The CLI rescues the base `Error`, prints the message to `stderr`, and exits with a non-zero status.

### Logging

`lib/r2/logging.rb`

`R2::Logging` builds the loggers used for diagnostics:

* `R2::Logging.build` returns a standard `Logger` writing to the error output when the `--verbose` flag is present, and a `NullLogger` otherwise.
* `NullLogger` silently discards debug messages, keeping collaborators free from nil checks.

The CLI builds the logger from the `--verbose` flag and shares it with `Storage` so diagnostics follow the requested verbosity.

## Data Flow

```text
CLI
 │
 ├── Configuration ──→ ENV
 │
 ├── Logging ←── --verbose
 │
 ├── $stdin ←── confirmation of destructive commands
 │
 └── Storage
      │
      ├── ContentType ──→ Content-Type of the object
      │
      └── Retry ──→ aws-sdk-s3 ──→ Cloudflare R2
                       │
                       └── failure → R2::Errors::*
                                       │
                                       └── CLI → stderr + exit 1
```

Transient network failures are retried by `Retry` before the error mapping, so a brief instability does not interrupt the operation.

## Testing

### Unit Tests

`spec/unit/`

Tests individual components in isolation: CLI, configuration, content type, errors, logging, retry and storage.

### Integration Tests

`spec/integration/`

Tests the interaction between the CLI and `Storage` using a fake S3 client, which reproduces the bucket behavior, including the pagination of the listing and the metadata requests.

The confirmation prompts are validated with a controlled standard input, so the suite never waits for a real user and the result does not depend on whether the runner has a terminal attached.

### End-to-End Tests

`spec/e2e/`

Tests the application against a real Cloudflare R2 bucket using `R2_TEST_BUCKET`.

These tests are skipped when the required credentials are unavailable.

## Design Decisions

### Direct Constructor Injection

No dependency-injection container is used. Dependencies are passed directly through constructors, keeping the architecture simple and explicit. `Storage`, for instance, receives its logger, retry policy and waiting strategy, which makes the retries testable without real waiting.

### Deletion Confirmation

Destructive commands confirm the operation before sending it, since a deletion cannot be undone. The confirmation depends on an interactive input, so scripts and pipelines must use `--force`: the alternative, deleting silently when no terminal is attached, would make accidental deletions possible in automated executions.

### Retries with Backoff

Transient network failures are retried with exponential backoff by the application, on top of the retries already performed by `aws-sdk-s3`. Keeping the behavior in the project makes it explicit, configurable and covered by the tests, instead of being an undocumented side effect of the SDK.

### Automatic Content Type

The content type is derived from the object key instead of the local file, because the key is what defines the object in the bucket and can differ from the name of the uploaded file (`--key`). Unmapped extensions fall back to `application/octet-stream`, the default of S3-compatible services.

### R2 Region

`R2_REGION` defaults to `auto`, which is the recommended region value for Cloudflare R2.

### Runtime XML Dependency

`rexml` is included as a required runtime dependency because it is used for XML parsing by `aws-sdk-s3`.
