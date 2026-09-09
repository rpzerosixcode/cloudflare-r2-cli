# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-09-09

### Added

* `r2 download` — downloads an object from the configured bucket, with
  `--output` to choose a custom destination path.
* `r2 upload --key` — stores the uploaded file under a custom object key.
* Global `--verbose` flag — writes detailed diagnostic information to the
  error output during execution.
* Internal logging support in the CLI and storage layers.
* `R2::Errors::ObjectNotFoundError` for missing objects.

### Changed

* Standardized success messages across commands:
  * `Uploaded successfully: <key>`
  * `Downloaded successfully: <destination>`
  * `Deleted successfully: <key>`
* Restructured the `README` with a table of contents and documentation for
  the new command, options and global flag.
* Integrated the documentation into the repository: architecture, features
  and security guides now live in `docs/`, replacing the dedicated docs
  branch.

## [1.0.0] - 2026-08-30

First stable release of `cloudflare-r2-cli`.

### Added

* Initial release with the essential commands to manage objects on Cloudflare R2:
  * `r2 upload` — uploads a file to the configured bucket.
  * `r2 delete` — deletes a file from the configured bucket.
  * `r2 list` — lists the files stored in the configured bucket.
* Configuration through environment variables (`R2_ACCESS_KEY_ID`,
  `R2_SECRET_ACCESS_KEY`, `R2_ENDPOINT`, `R2_REGION` and `R2_BUCKET`).
* Clear error messages and non-zero exit codes on failures.
* Unit, integration and E2E test suites.
* Continuous integration via GitHub Actions.

[Unreleased]: https://github.com/rpzerosixcode/cloudflare-r2-cli/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/rpzerosixcode/cloudflare-r2-cli/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/rpzerosixcode/cloudflare-r2-cli/releases/tag/v1.0.0