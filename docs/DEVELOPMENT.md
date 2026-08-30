# Development

## Branches

The project uses two main branches:

* `develop`: development.
* `main`: stable version.

## Pull Requests

Changes between branches must be made through Pull Requests.

Pull Requests must be clear, objective and pass the required checks before merging.

## Commits

Commits must follow the **Conventional Commits** convention, using types such as:

* `feat`: new feature.
* `fix`: bug fix.
* `docs`: documentation change.
* `refactor`: refactoring without behavior change.
* `test`: creation or change of tests.
* `chore`: maintenance tasks.

## Continuous Integration

The project uses **GitHub Actions** to automatically validate changes on every
push to the `develop` and `main` branches and on Pull Requests.

The workflow defined in `.github/workflows/ci.yml` runs:

* **Lint** — RuboCop.
* **Tests** — unit, integration and E2E suites. The E2E scenarios are marked
  as pending when the test credentials are not configured in the repository
  secrets (`R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_ENDPOINT`,
  `R2_REGION` and `R2_TEST_BUCKET`).
* **Packaging** — gem build (`rake build`).

## Releases

Releases are published from tags in the `v*` format (for example, `v1.0.0`).

The workflow defined in `.github/workflows/release.yml`:

* validates the project (lint, tests and packaging);
* publishes the gem to RubyGems using the `RUBYGEMS_API_KEY` repository secret;
* creates a GitHub Release with the packed gem attached.

To release a new version:

1. Update the version in `lib/r2/version.rb` and the changelog in `CHANGELOG.md`.
2. Merge the changes into `main`.
3. Create and push the version tag:
   ```console
   $ git tag v1.0.0
   $ git push origin v1.0.0
   ```

## Principles

Development must prioritize simplicity, organization and code maintenance.

Changes must remain aligned with the current scope of the project and its documentation.
