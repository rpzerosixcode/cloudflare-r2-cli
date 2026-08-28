# Arquitetura

## Estratégia de Testes

* [Testing](architecture/testing.md) — Estratégia e organização dos testes.

## Documentação

### Arquitetura

* [CLI](architecture/cli.md) — Estrutura e funcionamento da interface de linha de comando.
* [Configuration](architecture/configuration.md) — Organização e gerenciamento das configurações da aplicação.
* [Errors](architecture/errors.md) — Estratégia e organização do tratamento de erros.
* [Storage](architecture/storage.md) — Organização da camada responsável pelo armazenamento e persistência.
* [Testing](architecture/testing.md) — Estratégia e organização dos testes.

## Estrutura do projeto

> A estrutura não precisa ser atualizada continuamente, mas deve ser revisada e atualizada antes do release `1.0.0`.

```text
C:.
|   LICENCE
|   README.md
|
+---docs
|   |   ARCHITECTURE.md
|   |   DECISIONS.md
|   |   FEATURES.md
|   |   ROADMAP.md
|   |   SECURITY.md
|   |
|   \---architecture
|           cli.md
|           configuration.md
|           errors.md
|           storage.md
|
\---lib
```
