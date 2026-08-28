# Erros

Os erros serão centralizados para padronizar seu tratamento e manter o comportamento da aplicação consistente.

## Tratamento

No MVP, as exceções serão abstraídas para `R2::Errors::Error`, evitando expor erros específicos das implementações.

## Evolução

Uma hierarquia de erros mais específica poderá ser adotada futuramente caso seja necessária.
