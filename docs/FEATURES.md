# Funcionalidades

## MVP

### Upload

Envia um arquivo para o bucket do Cloudflare R2 configurado.

**Sintaxe:**

```console
$ r2 upload <arquivo>
```

**Exemplos:**

```console
$ r2 upload imagem.jpg
$ r2 upload ./imagens/foto.png
```

**Comportamento:**

* Valida se o arquivo informado existe.
* Valida se o caminho não corresponde a um diretório.
* Abre o arquivo em modo de leitura binária.
* Envia o conteúdo para o bucket configurado no Cloudflare R2.
* Utiliza o nome do arquivo como chave do objeto no bucket.
* Exibe uma mensagem de sucesso após o envio.

Em caso de erro, a mensagem correspondente é exibida e a CLI é encerrada com código de status diferente de zero.

**Status:** Implementado.

### Delete

Exclusão de arquivos armazenados no Cloudflare R2.

**Status:** Planejado.

### List

Listagem de arquivos armazenados no Cloudflare R2.

**Status:** Planejado.
