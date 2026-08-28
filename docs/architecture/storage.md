# Armazenamento

O armazenamento abstrai a comunicação com o Cloudflare R2, utilizando a gem
`aws-sdk-s3`.

## Dependências

A gem `aws-sdk-s3` requer um parser XML para processar as respostas da API.
O projeto depende de `rexml` para atender a esse requisito em tempo de
execução.

## Região

O endpoint do Cloudflare R2 é compatível com S3 e exige a definição de uma
região. A região é fornecida pela `Configuration` (via `R2_REGION`), usando o
padrão `auto`, recomendado para o Cloudflare R2.

## Responsabilidade

A camada é responsável exclusivamente pelo **envio de imagens**, recebendo o
conteúdo já preparado e entregando-o ao R2.

## Operações

### Upload

O método `upload` recebe a chave do objeto e o conteúdo e executa `put_object`
no bucket configurado, retornando a **etag** do objeto enviado.

Falhas na operação são abstraídas para `R2::Errors::Error`, evitando expor
erros específicos da implementação.

## Limites

A camada não deve:

* Ler ou localizar arquivos.
* Processar ou transformar conteúdo.
* Determinar a origem do conteúdo.

Essas responsabilidades pertencem às camadas que utilizam o armazenamento.

## Configuração do Bucket

O bucket é definido na configuração do `Storage` e não é informado
individualmente nas operações.

Essa abordagem atende ao MVP e poderá ser reavaliada futuramente caso uma
configuração mais dinâmica proporcione uma experiência melhor ao usuário.

## Nomeação dos Objetos

No MVP, a chave do objeto é baseada no **nome do arquivo de origem**.

Essa estratégia prioriza simplicidade e poderá ser substituída futuramente por
uma abordagem mais refinada, caso necessário.
