# Testes

Cada tipo de teste possui uma pasta própria, mantendo objetivos e responsabilidades separados.

## Testes Unitários

Localizados em `spec/unit/`.

Testam componentes isoladamente.

## Testes de Integração

Localizados em `spec/integration/`.

Testam a interação entre componentes.

## Testes E2E

Localizados em `spec/e2e/`.

Focam nos fluxos principais e resultados esperados, mantendo os cenários simples e sem testar detalhes internos.

## Ambiente

Os testes utilizam exclusivamente o bucket `test-bucket`, configurável por `R2_TEST_BUCKET`.

Arquivos temporários devem permanecer em `tmp/`, que deve estar no `.gitignore`.

Os recursos criados pelos testes devem ser limpos ao final da execução sempre que possível. Os testes E2E removem os objetos enviados ao final de cada cenário.

As credenciais podem ser fornecidas pelo `.env` ou pelo ambiente.

## Cobertura

Os testes devem cobrir os principais comportamentos, incluindo cenários de sucesso e erro.

Os testes E2E são uma exceção: devem permanecer extremamente simples e focados apenas nos fluxos principais.

## Execução

Executar toda a suíte:

```console
$ bundle exec rake