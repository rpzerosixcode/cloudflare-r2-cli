# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/rpzerosixcode/cloudflare-r2-cli/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/rpzerosixcode/cloudflare-r2-cli/releases/tag/v1.0.0