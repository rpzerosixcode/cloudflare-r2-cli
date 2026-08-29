# Erros

Os erros são centralizados para padronizar seu tratamento e manter o
comportamento da aplicação consistente.

## Hierarquia

Todos os erros de domínio herdam de `R2::Errors::Error`:

* `ConfigurationError` — configuração obrigatória ausente ou inválida.
* `FileNotFoundError` — o arquivo informado não existe.
* `InvalidFileError` — o caminho informado não corresponde a um arquivo.
* `PermissionError` — sem permissão para ler o arquivo informado.
* `BucketNotFoundError` — o bucket configurado não existe.
* `NetworkError` — falha de rede na comunicação com o Cloudflare R2.
* `StorageError` — falha não classificada na camada de armazenamento.

## Tratamento

As exceções específicas das implementações são convertidas para a hierarquia
de `R2::Errors`, evitando expor detalhes internos das bibliotecas e permitindo
que consumidores capturem o erro genérico ou um erro específico.

A CLI captura `R2::Errors::Error`, apresenta a mensagem na saída de erro e
encerra com código de status diferente de zero.
