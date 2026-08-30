# Decisions

This document records the main architectural and project-level decisions.

## Name

The publication name of the project is **`cloudflare-r2-cli`**.

For command usage, **`r2`** is used.

## Content

The project's public content is maintained in **English**.

## Changelog

Formal changelog maintenance starts with version **`1.0.0`** in
[CHANGELOG.md](../CHANGELOG.md).

## Versioning

The project follows **Semantic Versioning**, starting with version **`1.0.0`**.

## Dependency Injection

Dependencies should preferably be provided through **dependency injection**,
avoiding unnecessary coupling to concrete implementations.

The project does not use a dependency injection container. Dependencies are
provided directly by the components that require them.