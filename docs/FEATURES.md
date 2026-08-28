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

Exclui um arquivo armazenado no bucket do Cloudflare R2 configurado.

**Sintaxe:**

```console
$ r2 delete <arquivo>
```

**Exemplo:**

```console
$ r2 delete imagem.jpg
```

**Comportamento:**

* Recebe o nome do arquivo a ser excluído.
* Utiliza o nome do arquivo como chave do objeto.
* Solicita a exclusão do objeto ao Cloudflare R2.
* Considera a operação bem-sucedida quando o armazenamento conclui a solicitação sem erro.
* Exibe uma mensagem de sucesso após a operação.

A funcionalidade **não realiza uma consulta posterior para verificar se o objeto deixou de existir**. A confirmação de sucesso é baseada no resultado da operação de exclusão fornecido pela camada de armazenamento.

Em caso de erro na operação, a mensagem correspondente é exibida e a CLI é encerrada com código de status diferente de zero.

**Status:** Implementado.

### List

Lista os arquivos armazenados no bucket do Cloudflare R2 configurado.

**Sintaxe:**

```console id="zmjz6i"
$ r2 list
```

**Comportamento:**

* Consulta os objetos armazenados no bucket configurado.
* Exibe os arquivos encontrados.
* Não possui paginação ou controle da quantidade de objetos retornados durante o MVP.

> **Nota:** Paginação e controle da quantidade de objetos retornados poderão ser implementados futuramente, caso sejam necessários.

Em caso de erro na operação, a mensagem correspondente é exibida e a CLI é encerrada com código de status diferente de zero.

**Status:** Implementado.
