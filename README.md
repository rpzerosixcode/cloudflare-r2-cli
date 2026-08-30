# Cloudflare R2 CLI

Ruby CLI to manage objects on Cloudflare R2 from the terminal.

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
$ gem install pkg/cloudflare-r2-cli-1.0.0.gem
```

## Usage

### Configuration

Before using the CLI, define the required environment variables:

| Variable               | Description                                        |
| ---------------------- | -------------------------------------------------- |
| `R2_ACCESS_KEY_ID`     | Cloudflare R2 S3 access key ID.                    |
| `R2_SECRET_ACCESS_KEY` | Cloudflare R2 S3 secret access key.                |
| `R2_ENDPOINT`          | Cloudflare R2 S3-compatible endpoint.              |
| `R2_REGION`            | Region of the S3-compatible endpoint. *(optional, default `auto`)* |
| `R2_BUCKET`            | Default bucket used by the CLI.                    |

A fillable template is available in [`.env.example`](.env.example).

Credentials are read only from environment variables and must never be
inserted into code or versioned files. See
[`docs/SECURITY.md`](docs/SECURITY.md) for more details.

### Upload

Uploads an image to the configured bucket:

```console
$ r2 upload image.jpg
$ r2 upload ./images/photo.png
```

The object key in the bucket will be the name of the given file. On success,
a confirmation message is displayed.

### Delete

Deletes a file stored in the configured bucket:

```console
$ r2 delete image.jpg
```

The operation is confirmed by the result of the deletion returned by the service.

### List

Lists the files stored in the configured bucket:

```console
$ r2 list
```

On any error, the CLI displays the corresponding message on the error output
and exits with status code `1`.

## Development

The development guidelines, branches and commits are described in
[`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md).

### Tests

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

The E2E tests require real Cloudflare R2 credentials, provided by the `.env`
file or by the environment. Without them, the scenarios are marked as
pending and do not fail.

## Documentation

* [Architecture](docs/ARCHITECTURE.md) — Overview of the project architecture.
* [Changelog](CHANGELOG.md) — Version history of the project.
* [Decisions](docs/DECISIONS.md) — Architecture and project decisions.
* [Features](docs/FEATURES.md) — Planned and implemented features.
* [Roadmap](docs/ROADMAP.md) — Planned evolution of the project.
* [Security](docs/SECURITY.md) — General security guidelines of the project.
* [Development](docs/DEVELOPMENT.md) — Development guidelines of the project.

## License

[MIT License](./LICENCE) — Terms of use and distribution of the project.
