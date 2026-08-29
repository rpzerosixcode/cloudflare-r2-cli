# Desenvolvimento

## Branches

O projeto utiliza duas branches principais:

* `develop`: desenvolvimento.
* `main`: versão estável.

## Pull Requests

As alterações entre branches devem ser realizadas por meio de Pull Requests.

Pull Requests devem ser claros, objetivos e passar pelas verificações necessárias antes do merge.

## Commits

Os commits devem seguir a convenção **Conventional Commits**, utilizando tipos como:

* `feat`: nova funcionalidade.
* `fix`: correção de um problema.
* `docs`: alteração na documentação.
* `refactor`: refatoração sem alteração de comportamento.
* `test`: criação ou alteração de testes.
* `chore`: tarefas de manutenção.

## Integração Contínua

O projeto utiliza **GitHub Actions** para validar automaticamente as alterações
a cada push nas branches `develop` e `main` e em Pull Requests.

O fluxo definido em `.github/workflows/ci.yml` executa:

* **Matriz de ambientes** — Ubuntu, macOS e Windows, com Ruby `3.0` a `3.3`.
* **Estilo** — RuboCop em todas as plataformas, incluindo a verificação do
  fim de linha (LF).
* **Testes** — suíte de unidade e integração.
* **Empacotamento** — construção da gem (`rake build`).
* **E2E** — executado no Ubuntu; os cenários são marcados como pendentes quando
  as credenciais de teste não estão configuradas nos segredos
  (`R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_ENDPOINT`, `R2_REGION` e
  `R2_TEST_BUCKET`).

## Princípios

O desenvolvimento deve priorizar simplicidade, organização e manutenção do código.

As alterações devem permanecer alinhadas ao escopo atual do projeto e sua documentação.
