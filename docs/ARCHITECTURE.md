# Architecture

## Test Strategy

* [Testing](architecture/testing.md) — Test strategy and organization.

## Documentation

### Architecture

* [CLI](architecture/cli.md) — Structure and operation of the command line interface.
* [Configuration](architecture/configuration.md) — Organization and management of the application settings.
* [Errors](architecture/errors.md) — Strategy and organization of error handling.
* [Storage](architecture/storage.md) — Organization of the storage and persistence layer.
* [Testing](architecture/testing.md) — Test strategy and organization.

## Project Structure

```text
C:.
|   CHANGELOG.md
|   LICENCE
|   README.md
|   Rakefile
|   r2.gemspec
|   Gemfile
|   Gemfile.lock
|   .env.example
|   .gitattributes
|   .gitignore
|   .rspec
|   .rubocop.yml
|
+---.github
|   \---workflows
|           ci.yml
|           release.yml
|
+---bin
|       r2
|
+---docs
|   |   ARCHITECTURE.md
|   |   DECISIONS.md
|   |   DEVELOPMENT.md
|   |   FEATURES.md
|   |   ROADMAP.md
|   |   SECURITY.md
|   |
|   \---architecture
|           cli.md
|           configuration.md
|           errors.md
|           storage.md
|           testing.md
|
+---lib
|   |   r2.rb
|   |
|   \---r2
|           cli.rb
|           configuration.rb
|           errors.rb
|           storage.rb
|           version.rb
|
\---spec
    |   spec_helper.rb
    |
    +---e2e
    |       e2e_spec.rb
    |
    +---integration
    |       cli_storage_spec.rb
    |
    +---support
    |       cleanup.rb
    |       cli_expectations.rb
    |       cli_runner.rb
    |       e2e_helper.rb
    |       env_helper.rb
    |       fake_s3_client.rb
    |       output_capture.rb
    |       temp_file_helper.rb
    |
    \---unit
            cli_spec.rb
            configuration_spec.rb
            errors_spec.rb
            storage_spec.rb
            version_spec.rb
```
