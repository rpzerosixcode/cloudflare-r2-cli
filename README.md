# Cloudflare R2 CLI

CLI em Ruby para gerenciar objetos no Cloudflare R2 pelo terminal.

## Requisitos

* Ruby **3.0** ou superior.

## Instalação

### A partir de uma gem publicada

```console
$ gem install cloudflare-r2-cli
```

### A partir do código-fonte

```console
$ git clone https://github.com/rpzerosixcode/cloudflare-r2-cli.git
$ cd cloudflare-r2-cli
$ bundle install
$ bundle exec rake build
$ gem install pkg/cloudflare-r2-cli-0.0.0.gem
```

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

As credenciais são lidas apenas de variáveis de ambiente e nunca devem ser
inseridas em código ou em arquivos versionados. Consulte
[`docs/SECURITY.md`](docs/SECURITY.md) para mais detalhes.

### Upload

Envia uma imagem para o bucket configurado:

```console
$ r2 upload imagem.jpg
$ r2 upload ./imagens/foto.png
```

A chave do objeto no bucket será o nome do arquivo informado. Em caso de
sucesso, uma mensagem de confirmação é exibida.

### Delete

Exclui um arquivo armazenado no bucket configurado:

```console
$ r2 delete imagem.jpg
```

A operação é confirmada pelo resultado da exclusão retornado pelo serviço.

### List

Lista os arquivos armazenados no bucket configurado:

```console
$ r2 list
```

Em qualquer erro, a CLI exibe a mensagem correspondente na saída de erro e
encerra com código de status `1`.

## Desenvolvimento

As diretrizes de desenvolvimento, branches e commits estão descritas em
[`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md).

### Testes

Executar toda a suíte (unidade, integração e E2E):

```console
$ bundle exec rake
```

Executar apenas um nível:

```console
$ bundle exec rake unit
$ bundle exec rake integration
$ bundle exec rake e2e
```

Os testes E2E exigem credenciais reais do Cloudflare R2, fornecidas pelo
arquivo `.env` ou pelo ambiente. Sem elas, os cenários são marcados como
pendentes (`pending`) e não falham.

## Documentação

* [Arquitetura](docs/ARCHITECTURE.md) — Visão geral da arquitetura do projeto.
* [Decisões](docs/DECISIONS.md) — Decisões de arquitetura e de projeto.
* [Funcionalidades](docs/FEATURES.md) — Funcionalidades previstas e implementadas.
* [Roadmap](docs/ROADMAP.md) — Evolução planejada do projeto.
* [Segurança](docs/SECURITY.md) — Diretrizes gerais de segurança do projeto.
* [Desenvolvimento](docs/DEVELOPMENT.md) — Diretrizes de desenvolvimento do projeto.

## Licença

[Licença MIT](./LICENCE) — Termos de uso e distribuição do projeto.
