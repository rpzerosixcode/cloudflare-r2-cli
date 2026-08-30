# Testing

Each test type has its own folder, keeping objectives and responsibilities
separated.

## Unit Tests

Located in `spec/unit/`.

Test components in isolation.

## Integration Tests

Located in `spec/integration/`.

Test the interaction between components.

## E2E Tests

Located in `spec/e2e/`.

Focus on the main flows and expected results, keeping the scenarios simple and
avoiding tests of internal implementation details.

## Environment

Tests use a dedicated bucket configured through `R2_TEST_BUCKET`.

Temporary files must remain in `tmp/`, which must be included in `.gitignore`.

Resources created by tests must be cleaned up at the end of execution whenever
possible. E2E tests remove uploaded objects at the end of each scenario.

Credentials can be provided through the `.env` file or the environment.

## Coverage

Tests must cover the main behaviors, including success and error scenarios.

E2E tests are an exception: they must remain extremely simple and focused only
on the main user flows.

## Execution

Run the full test suite:

```console
$ bundle exec rake