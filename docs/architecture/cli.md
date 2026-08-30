# CLI

The CLI is responsible for interpreting the user's input, executing the
corresponding actions and presenting the results.

The `thor` gem is used to define and execute the commands.

## Responsibility

The CLI acts as a **minimal orchestrator**, coordinating the operations at a
high level.

## Boundaries

The CLI must not implement business rules, directly handle files or know
details of the implementations and services used.

The execution of the operations must be delegated to the responsible
components.

## Commands

The available commands and their behaviors are documented in
[FEATURES.md](../FEATURES.md).
