# Storage

The storage abstracts the communication with Cloudflare R2, using the
`aws-sdk-s3` gem.

## Dependencies

The `aws-sdk-s3` gem requires an XML parser. The project uses `rexml` to meet
this requirement at runtime.

## Responsibility

The layer is responsible for communicating with Cloudflare R2, receiving the
data prepared by the upper layers and executing the storage operations.

## Region

The region is provided by the `Configuration` through `R2_REGION`, using `auto`
as the default.

## Boundaries

The layer must not:

* Read or locate files.
* Process or transform content.
* Determine the origin of the content.

These responsibilities belong to the layers that use the storage.

## Configuration

The bucket is defined by the `Storage` configuration and is not informed
individually in each operation.

Details of the features and their behavior for the user are documented in
[FEATURES.md](../FEATURES.md).

## Errors

The client failures are converted to the `R2::Errors` hierarchy:

* `Errors::ConfigurationError` — missing or invalid access credentials.
* `Errors::BucketNotFoundError` — the configured bucket does not exist.
* `Errors::NetworkError` — network failure in the communication.
* `Errors::StorageError` — other failures of the storage layer.
