# Segurança

As principais medidas de segurança do projeto são:

* **Credenciais por variáveis de ambiente** — as credenciais de acesso e as
  configurações sensíveis são obtidas exclusivamente de variáveis de ambiente,
  nunca do código-fonte ou de arquivos versionados.
* **Ambiente de teste isolado** — os testes E2E utilizam um bucket dedicado
  (`R2_TEST_BUCKET`), separado do bucket padrão da aplicação.
* **Arquivos de ambiente ignorados** — o arquivo `.env` e suas variantes não
  são rastreados pelo Git; apenas o modelo `.env.example` é versionado.
* **CI e segredos** — no fluxo de integração contínua, as credenciais são
  fornecidas por segredos do repositório e nunca são exibidas nos logs.

Se uma chave de acesso for exposta acidentalmente, revogue-a imediatamente no
painel do Cloudflare e gere uma nova.
