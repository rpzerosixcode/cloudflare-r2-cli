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

> A estrutura não precisa ser atualizada continuamente, mas deve ser revisada e
> atualizada antes do release `1.0.0`.

```text
C:.
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
