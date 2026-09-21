# Features

## Upload

Uploads a file to the configured Cloudflare R2 bucket.

**Usage:**

```console
$ r2 upload <file> [--key <key>]
```

**Examples:**

```console
$ r2 upload image.jpg
$ r2 upload ./images/photo.png
$ r2 upload ./images/photo.png --key uploads/photo.png
```

**Behavior:**

* Validates that the given file exists.
* Validates that the path is not a directory.
* Opens the file in binary read mode.
* Defines the `Content-Type` of the object from the extension of its key, falling back to `application/octet-stream` when the extension is not mapped.
* Uploads the content to the configured Cloudflare R2 bucket.
* Uses the file name as the object key in the bucket, or the custom key given via `--key`.
* Displays a success message after the upload.

On error, the corresponding message is displayed and the CLI exits with a non-zero status code.

## Download

Downloads a file stored in the configured Cloudflare R2 bucket.

**Usage:**

```console
$ r2 download <key> [--output <path>]
```

**Examples:**

```console
$ r2 download image.jpg
$ r2 download image.jpg --output ./images/photo.png
```

**Behavior:**

* Receives the object key to download.
* Streams the content directly to the destination file, so large objects do not need to be fully loaded into memory.
* Writes the content to a file named after the object key in the current directory, unless `--output` chooses a custom destination path.
* Displays a success message after the download.

On error, the corresponding message is displayed and the CLI exits with a non-zero status code.

## Delete

Deletes a file stored in the configured Cloudflare R2 bucket.

**Usage:**

```console
$ r2 delete <file> [--force]
```

**Examples:**

```console
$ r2 delete image.jpg
$ r2 delete image.jpg --force
```

**Behavior:**

* Receives the name of the file to delete.
* Asks for the confirmation of the deletion before sending the request, unless `--force` is given.
* Uses the file name as the object key.
* Requests the object deletion from Cloudflare R2.
* Considers the operation successful when the storage completes the request without errors.
* Displays a success message after the operation.

**Confirmation:**

The prompt is written to the standard output and the answer is read from the standard input:

```console
$ r2 delete image.jpg
Delete "image.jpg" from the bucket? [y/N]
```

The deletion only proceeds with an affirmative answer (`y` or `yes`); any other answer, including an empty one, aborts the operation. In non-interactive executions, such as scripts and pipelines, the confirmation cannot be requested, so the CLI aborts with an explanatory message and status code `1`. Use `--force` to delete without confirmation:

```console
$ r2 delete image.jpg --force
```

The feature does not perform a follow-up query to check that the object no longer exists. The success confirmation is based on the result of the deletion operation provided by the storage layer.

On error, the corresponding message is displayed and the CLI exits with a non-zero status code.

## List

Lists the files stored in the configured Cloudflare R2 bucket.

**Usage:**

```console
$ r2 list [--prefix <prefix>]
```

**Examples:**

```console
$ r2 list
$ r2 list --prefix uploads/
```

**Behavior:**

* Queries the objects stored in the configured bucket.
* Follows the pagination of the bucket, requesting every page until the last one, so all objects are returned.
* Lists only the objects whose keys start with the given prefix, when `--prefix` is used.
* Displays the files found.

On error, the corresponding message is displayed and the CLI exits with a non-zero status code.

## Exists

Checks whether an object exists in the configured Cloudflare R2 bucket.

**Usage:**

```console
$ r2 exists <key>
```

**Examples:**

```console
$ r2 exists image.jpg
```

**Behavior:**

* Requests the metadata of the object, instead of its content, so the check does not depend on the object size.
* Displays `Object exists: <key>` and exits with status code `0` when the object exists.
* Displays `Object not found: <key>` and exits with status code `1` when the object does not exist, allowing the command to be used in scripts.

On error, the corresponding message is displayed and the CLI exits with a non-zero status code.

## Reliability

### Automatic retries

Transient failures while communicating with Cloudflare R2, such as brief network instabilities, are retried automatically with exponential backoff:

| Attempt | Wait before the attempt |
| ------- | ----------------------- |
| 1       | —                       |
| 2       | 0.5s                    |
| 3       | 1s                      |

The wait is capped at 5s, and the operation fails after the last attempt, reporting the mapped domain error. Failures that are not transient, such as missing credentials, an invalid bucket or a missing object, are reported immediately, without retries.

The retries are applied to every storage operation and restart from the beginning of the data: the uploaded content is rewound and the downloaded content is written from the start again, so a retried request never sends an incomplete body or leaves a partially written file.

### Diagnostics

With `--verbose`, every retry is reported on the error output with the operation, the failure cause and the wait applied:

```console
$ r2 upload image.jpg --verbose
Retrying upload of image.jpg in 0.5s (attempt 2 of 3) after a transient failure: Seahorse::Client::NetworkingError: ...
```

## Global Options

Every command accepts the global `--verbose` flag, which writes detailed diagnostic information to the error output without changing the standard output:

```console
$ r2 list --verbose
$ r2 upload image.jpg --verbose
$ r2 download image.jpg --verbose
$ r2 delete image.jpg --force --verbose
$ r2 exists image.jpg --verbose
```

Without the flag, diagnostics are discarded by a null logger and only the standard output is produced.
