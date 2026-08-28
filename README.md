# Cloudflare R2 CLI

CLI em Ruby para gerenciar objetos no Cloudflare R2 pelo terminal.

## Instalação

> A definir durante o desenvolvimento.

## Uso

### Configuração

Antes de usar o CLI, defina as variáveis de ambiente necessárias:

| Variável               | Descrição                                              |
| ---------------------- | ------------------------------------------------------ |
| `R2_ACCESS_KEY_ID`     | ID da chave de acesso S3 do Cloudflare R2.             |
| `R2_SECRET_ACCESS_KEY` | Chave de acesso secreta S3 do Cloudflare R2.           |
| `R2_ENDPOINT`          | Endpoint compatível com S3 do Cloudflare R2.           |
| `R2_REGION`            | Região do endpoint compatível com S3. *(opcional, padrão `auto`)* |
| `R2_BUCKET`            | Bucket padrão utilizado pelo CLI.                      |

Um modelo preenchível está disponível em [`.env.example`](.env.example).

### Upload

Envia uma imagem para o bucket configurado:

```console
$ r2 upload imagem.jpg
$ r2 upload ./imagens/foto.png
```

A chave do objeto no bucket será o nome do arquivo informado. Em caso de
sucesso, a etag do objeto enviado é exibida.

## Documentação

* [Arquitetura](docs/ARCHITECTURE.md) — Visão geral da arquitetura do projeto.
* [Decisões](docs/DECISIONS.md) — Decisões de arquitetura e de projeto.
* [Funcionalidades](docs/FEATURES.md) — Funcionalidades previstas e implementadas.
* [Roadmap](docs/ROADMAP.md) — Evolução planejada do projeto.
* [Segurança](docs/SECURITY.md) — Diretrizes gerais de segurança do projeto.
* [Desenvolvimento](docs/DEVELOPMENT.md) — Diretrizes de desenvolvimento do projeto.

## Licença

[Licença MIT](./LICENCE) — Termos de uso e distribuição do projeto.
