# Arquitetura

## Fluxo de Dados

### Upload

1. O usuário executa o comando `r2 upload <arquivo>`.
2. A CLI valida o arquivo e o abre para leitura.
3. A CLI delega o envio ao `Storage`, informando a chave e o conteúdo.
4. O `Storage` envia o conteúdo ao Cloudflare R2 por meio da gem `aws-sdk-s3`.
5. O `Storage` retorna a etag do objeto enviado.
6. A CLI apresenta o resultado ao usuário.

## Estratégia de Testes

> A definir durante o desenvolvimento.

## Documentação

### Arquitetura

* [CLI](architecture/cli.md) — Estrutura e funcionamento da interface de linha de comando.
* [Configuration](architecture/configuration.md) — Organização e gerenciamento das configurações da aplicação.
* [Errors](architecture/errors.md) — Estratégia e organização do tratamento de erros.
* [Storage](architecture/storage.md) — Organização da camada responsável pelo armazenamento e persistência.

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
