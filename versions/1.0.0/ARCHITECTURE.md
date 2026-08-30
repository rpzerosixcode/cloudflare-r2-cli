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

* Uploading objects.
* Deleting objects.
* Listing objects.

`Storage` does not:

* Read local files.
* Transform content.
* Determine object keys.
* Read configuration directly from `ENV`.

The bucket is provided by `Configuration` rather than passed to individual operations.

### Errors

`lib/r2/errors.rb`

Defines the application's domain-level errors.

All errors inherit from `R2::Errors::Error`. Exceptions raised by `aws-sdk-s3` are mapped to specific application errors:

* `ConfigurationError`
* `BucketNotFoundError`
* `NetworkError`
* `StorageError`

This prevents callers from depending on AWS SDK-specific exceptions.

The CLI rescues the base `Error`, prints the message to `stderr`, and exits with a non-zero status.

## Data Flow

```text
CLI
 │
 ├── Configuration ──→ ENV
 │
 └── Storage ──→ aws-sdk-s3 ──→ Cloudflare R2
                      │
                      └── failure → R2::Errors::*
                                      │
                                      └── CLI → stderr + exit 1
```

## Testing

### Unit Tests

`spec/unit/`

Tests individual components in isolation.

### Integration Tests

`spec/integration/`

Tests the interaction between the CLI and `Storage` using a fake S3 client.

### End-to-End Tests

`spec/e2e/`

Tests the application against a real Cloudflare R2 bucket using `R2_TEST_BUCKET`.

These tests are skipped when the required credentials are unavailable.

## Design Decisions

### Direct Constructor Injection

No dependency-injection container is used. Dependencies are passed directly through constructors, keeping the architecture simple and explicit.

### R2 Region

`R2_REGION` defaults to `auto`, which is the recommended region value for Cloudflare R2.

### Runtime XML Dependency

`rexml` is included as a required runtime dependency because it is used for XML parsing by `aws-sdk-s3`.
