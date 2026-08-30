# Roadmap

The roadmap tracks the planned evolution of the project.

## MVP

The MVP was completed through the phases below.

### Phase 1 — Initial Preparation

Initial structure and fundamental project definitions.

### Phase 2 — Features

Implementation of the essential MVP features.

#### Phase 2.1 — Upload

Implementation of the upload feature.

#### Phase 2.2 — Delete

Implementation of the delete feature.

#### Phase 2.3 — List

Implementation of the list feature.

### Phase 3 — Test Coverage

Implementation and expansion of the project's test coverage.

### Phase 4 — Refinement and Stabilization

Review, refinement and stabilization of the project.

- **Portability** — ensure the CLI works in different environments and operating systems.
- **Consistency** — review and standardize code, tests, messages and behaviors.
- **Error handling** — review exception handling and ensure clear, safe messages.
- **Security** — review settings and ensure sensitive information is not exposed.
- **Documentation** — review and update the public documentation according to the current state of the project.
- **Development context** — remove or isolate documentation exclusively related to the development process.
- **Packaging** — validate the build, installation and execution of the distributed package.
- **Continuous integration** — integrate the CI flow into the development process, ensuring automated execution of tests and checks.
- **Final validation** — run the full test suite and validate the project in a clean environment.

### Phase 5 — Release

Preparation and publication of the first stable version of the project.

- **Versioning** — adopt semantic versioning from `1.0.0`.
- **Changelog** — start formal changelog maintenance from `1.0.0`.
- **Documentation** — normalize the public documentation according to the stable version.
- **Development context** — remove or isolate development-specific documentation that is no longer relevant.
- **MVP context** — remove or update MVP-specific notes and references that no longer apply to the stable version.
- **Translation** — translate and standardize the project content to English.
- **Release validation** — validate the version, build and release artifacts before publication.
- **Publication** — publish the `cloudflare-r2-cli` package on RubyGems.
- **Post-release validation** — install the published package in a clean environment and confirm it works.

## Future Evolution

Possible next steps for the project:

- **Pagination and control of the number of returned objects** in the `list` command.
- **Additional configuration sources** such as files and command-line flags.
- **Multipart uploads** for large files.

> **Note:** The focus will remain a **minimally scalable base** and **essential features**, not optimizations.