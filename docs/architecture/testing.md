# Testes

Cada tipo de teste possui uma pasta própria, mantendo seus objetivos e responsabilidades separados.

## Testes Unitários

Localizados em:

```text
spec/unit/
```

Testam componentes isoladamente.

## Testes de Integração

Localizados em:

```text
spec/integration/
```

Testam a interação entre componentes.

## Testes E2E

Localizados em:

```text
spec/e2e/
```

Focam em comportamentos simples e diretos, verificando apenas se os fluxos funcionam ou não.

* Verificar fluxos principais.
* Validar resultados esperados.
* Manter cenários simples.
* Evitar detalhes internos.

## Ambiente de Testes

Os dados utilizados nos testes serão armazenados exclusivamente no bucket `test-bucket`, mantendo-os isolados do ambiente de produção.

Os testes também podem gerar arquivos temporários localmente. Esses arquivos devem permanecer exclusivamente em `tmp/`, não sendo criados ou mantidos de forma aberta na estrutura do projeto.

O diretório `tmp/` deve ser ignorado pelo `.gitignore`, garantindo que arquivos temporários, artefatos de execução e outros resíduos gerados pelos testes não sejam versionados.

A limpeza do bucket e as ferramentas relacionadas serão implementadas quando houver necessidade real e recursos mínimos adequados para isso. Até então, os dados permanecerão isolados no ambiente de testes.

O bucket padrão é `test-bucket` e pode ser alterado pela variável de ambiente `R2_TEST_BUCKET`.

## Cobertura

Os testes devem cobrir os principais comportamentos, incluindo cenários de sucesso e erro.

## Execução

A suíte de testes pode ser executada com um único comando:

```console
$ bundle exec rake
```

Para executar apenas os testes E2E:

```console
$ bundle exec rake e2e
```

Os testes utilizam as credenciais do arquivo `.env` ou do ambiente e operam exclusivamente no bucket de testes.
