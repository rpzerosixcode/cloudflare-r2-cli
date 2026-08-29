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

Os recursos utilizados pelos testes devem ser limpos ao final da execução sempre que houver suporte adequado para isso. A limpeza deve utilizar as ferramentas e recursos já disponíveis no projeto, evitando a introdução de mecanismos adicionais sem necessidade.

Os testes E2E também removem do bucket de testes, ao final de cada cenário, os objetos enviados durante o teste, utilizando a própria camada de armazenamento do projeto.

O bucket padrão é `test-bucket` e pode ser alterado pela variável de ambiente `R2_TEST_BUCKET`.

## Cobertura

Os testes devem cobrir os principais comportamentos, incluindo cenários de sucesso e erro.

Os testes E2E são uma exceção: devem permanecer extremamente simples, focados apenas nos fluxos principais e nos resultados esperados, sem buscar cobertura exaustiva de cenários ou detalhes internos.

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
