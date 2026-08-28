# CLI

A CLI é responsável por interpretar as entradas do usuário, executar as ações correspondentes e apresentar os resultados.

É utilizada a gem `thor` para definição e execução dos comandos.

## Responsabilidade

A CLI atua como um **orquestrador mínimo**, coordenando as operações em alto nível.

## Limites

A CLI não deve implementar regras de negócio, manipular diretamente arquivos ou conhecer detalhes das implementações e serviços utilizados.

A execução das operações deve ser delegada aos componentes responsáveis.

## Comandos

Os comandos disponíveis e seus comportamentos são documentados em [FEATURES.md](../FEATURES.md).
