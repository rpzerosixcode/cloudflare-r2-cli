# Roadmap — v1.2.0

---

## Robustez e Usabilidade

### Armazenamento

* [x] Implementar paginação no `Storage#list`
* [x] Adicionar suporte a `prefix` no `Storage#list`
* [x] Definir `Content-Type` automaticamente no upload
* [x] Implementar tentativas automáticas com backoff para falhas de rede

### CLI

* [x] Adicionar confirmação antes do `delete`
* [x] Adicionar opção `--force` para ignorar a confirmação
* [x] Adicionar comando `exists` ou `info`
* [x] Atualizar testes unitários e de integração

### Objetivo

Tornar as operações existentes mais seguras, previsíveis e confiáveis para uso em ambientes reais, mantendo o escopo da versão focado no aprimoramento do CRUD existente.

---

## Entregas

* `Storage#list` percorre a paginação do bucket (`continuation_token`) e aceita
  `prefix`, exposto na CLI através de `r2 list --prefix`.
* `Storage#upload` define o `Content-Type` a partir da chave do objeto, através
  de `R2::ContentType`, e rebobina o conteúdo antes de cada tentativa.
* `R2::Retry` aplica tentativas automáticas com backoff exponencial
  (0.5s, 1s; teto de 5s; 3 tentativas) em todas as operações do storage,
  reiniciando o envio/escrita do conteúdo em cada tentativa.
* `Storage#exists?` verifica a existência de um objeto a partir de seus
  metadados.
* `r2 delete` pede confirmação antes de excluir e exige `--force` em execuções
  não interativas.
* `r2 exists KEY` informa se o objeto existe, retornando status `0` quando
  existe e `1` quando não existe.
* Testes unitários, de integração e E2E atualizados, com um S3 falso que
  reproduz paginação, prefixo e metadados, e com a entrada padrão controlada
  nos cenários de confirmação.
