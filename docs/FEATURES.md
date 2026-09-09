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
$ r2 delete <file>
```

**Example:**

```console
$ r2 delete image.jpg
```

**Behavior:**

* Receives the name of the file to delete.
* Uses the file name as the object key.
* Requests the object deletion from Cloudflare R2.
* Considers the operation successful when the storage completes the request without errors.
* Displays a success message after the operation.

The feature does not perform a follow-up query to check that the object no longer exists. The success confirmation is based on the result of the deletion operation provided by the storage layer.

On error, the corresponding message is displayed and the CLI exits with a non-zero status code.

## List

Lists the files stored in the configured Cloudflare R2 bucket.

**Usage:**

```console
$ r2 list
```

**Behavior:**

* Queries the objects stored in the configured bucket.
* Displays the files found.
* Returns all objects without pagination or control over the amount of returned objects.

On error, the corresponding message is displayed and the CLI exits with a non-zero status code.

## Global Options

Every command accepts the global `--verbose` flag, which writes detailed diagnostic information to the error output without changing the standard output:

```console
$ r2 list --verbose
$ r2 upload image.jpg --verbose
```

Without the flag, diagnostics are discarded by a null logger and only the standard output is produced.
