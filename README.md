# Cloudflare R2 CLI

Ruby CLI to manage objects on Cloudflare R2 from the terminal.

## Table of Contents

* [Requirements](#requirements)
* [Installation](#installation)
* [Configuration](#configuration)
* [Usage](#usage)
  * [Upload](#upload)
  * [Download](#download)
  * [Delete](#delete)
  * [List](#list)
  * [Global Options](#global-options)
* [Testing](#testing)
* [Changelog](#changelog)
* [License](#license)
* [Documentation](#documentation)

## Requirements

* Ruby **3.3** or higher.

## Installation

### From a published gem

```console
$ gem install cloudflare-r2-cli
```

### From the source code

```console
$ git clone https://github.com/rpzerosixcode/cloudflare-r2-cli.git
$ cd cloudflare-r2-cli
$ bundle install
$ bundle exec rake build
$ gem install pkg/cloudflare-r2-cli-1.1.0.gem
```

## Configuration

Before using the CLI, define the required environment variables:

| Variable               | Description                                                        |
| ---------------------- | ------------------------------------------------------------------ |
| `R2_ACCESS_KEY_ID`     | Cloudflare R2 S3 access key ID.                                    |
| `R2_SECRET_ACCESS_KEY` | Cloudflare R2 S3 secret access key.                                |
| `R2_ENDPOINT`          | Cloudflare R2 S3-compatible endpoint.                              |
| `R2_REGION`            | Region of the S3-compatible endpoint. *(optional, default `auto`)* |
| `R2_BUCKET`            | Default bucket used by the CLI.                                    |

A fillable template is available in `.env.example`.

Credentials are read only from environment variables and must never be inserted into code or versioned files. If an access key is accidentally exposed, revoke it immediately through the Cloudflare dashboard and generate a new one.

## Usage

### Upload

Uploads a file to the configured bucket:

```console
$ r2 upload image.jpg
$ r2 upload ./images/photo.png
$ r2 upload ./images/photo.png --key uploads/photo.png
```

By default, the object key in the bucket is the name of the given file. Use `--key` to store the object under a custom key. On success, a confirmation message is displayed.

### Download

Downloads a file stored in the configured bucket:

```console
$ r2 download image.jpg
$ r2 download image.jpg --output ./images/photo.png
```

By default, the content is written to a file with the object key base name in the current directory. Use `--output` to choose a custom destination path. On success, a confirmation message is displayed.

### Delete

Deletes a file stored in the configured bucket:

```console
$ r2 delete image.jpg
```

On success, a confirmation message is displayed.

### List

Lists the files stored in the configured bucket:

```console
$ r2 list
```

### Global Options

Every command accepts the global `--verbose` flag, which writes detailed diagnostic information to the error output without changing the standard output:

```console
$ r2 list --verbose
$ r2 upload image.jpg --verbose
$ r2 download image.jpg --verbose
$ r2 delete image.jpg --verbose
```

On any error, the CLI displays the corresponding message on the error output and exits with status code `1`.

## Testing

Run the full suite (unit, integration and E2E):

```console
$ bundle exec rake
```

Run only one level:

```console
$ bundle exec rake unit
$ bundle exec rake integration
$ bundle exec rake e2e
```

The E2E tests require real Cloudflare R2 credentials, provided by the `.env` file or by the environment. Without them, the scenarios are marked as pending and do not fail.

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md) for the version history of the project.

## License

[MIT License](./LICENSE) — Terms of use and distribution of the project.

## Documentation

Additional guides are versioned with the code in the `docs/` directory:

* [Features](docs/FEATURES.md) — commands, options and behaviors.
* [Architecture](docs/ARCHITECTURE.md) — layers, data flow, testing and design decisions.
* [Security](docs/SECURITY.md) — security practices adopted by the project.