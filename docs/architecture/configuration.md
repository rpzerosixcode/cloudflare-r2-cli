# Configuração

A `Configuration` centralizará as configurações da aplicação.

## Origem

As configurações serão obtidas diretamente de **variáveis de ambiente**, mantendo o MVP simples. Os demais componentes não devem acessar `ENV` diretamente.

## Variáveis

As variáveis obrigatórias são `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`,
`R2_ENDPOINT` e `R2_BUCKET`.

A variável `R2_REGION` é opcional e, quando ausente, usa o valor padrão `auto`,
recomendado para o Cloudflare R2.

## Evolução

A origem das configurações poderá ser diversificada futuramente caso surja uma necessidade real.
