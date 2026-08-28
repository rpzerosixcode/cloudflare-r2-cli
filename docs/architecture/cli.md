# CLI

A CLI é responsável por interpretar as entradas do usuário, executar as ações
correspondentes e apresentar os resultados.

É utilizada a gem `thor` para definição e execução dos comandos.

## Responsabilidade

A CLI atua como um **orquestrador mínimo**, coordenando as operações em alto
nível.

## Limites

A CLI não deve implementar regras de negócio, manipular diretamente imagens ou
arquivos, nem conhecer detalhes das implementações ou serviços utilizados.

A execução dos detalhes deve ser delegada aos componentes responsáveis.

## Comandos

### Upload

O comando `upload` recebe o caminho de um arquivo e o envia ao bucket do
Cloudflare R2 configurado.

```console
$ r2 upload imagem.jpg
$ r2 upload ./imagens/foto.png
```

Comportamento:

* Valida se o arquivo existe e se o caminho não é um diretório.
* Abre o arquivo em modo de leitura binária e o fornece à camada de
  armazenamento.
* Exibe a etag do objeto enviado em caso de sucesso.
* No MVP, a chave do objeto no bucket é o nome do arquivo informado.

Em caso de erro, a mensagem é exibida e a CLI é encerrada com código de status
diferente de zero.
