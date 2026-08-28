# Armazenamento

O armazenamento abstrai a comunicação com o Cloudflare R2, utilizando a gem `aws-sdk-s3`.

## Dependências

A gem `aws-sdk-s3` requer um parser XML. O projeto utiliza `rexml` para atender esse requisito em tempo de execução.

## Responsabilidade

A camada é responsável pela comunicação com o Cloudflare R2, recebendo os dados preparados pelas camadas superiores e executando as operações de armazenamento.

## Região

A região é fornecida pela `Configuration` por meio de `R2_REGION`, utilizando `auto` como padrão.

## Limites

A camada não deve:

* Ler ou localizar arquivos.
* Processar ou transformar conteúdo.
* Determinar a origem do conteúdo.

Essas responsabilidades pertencem às camadas que utilizam o armazenamento.

## Configuração

O bucket é definido pela configuração do `Storage` e não é informado individualmente em cada operação.

Detalhes das funcionalidades e seu comportamento para o usuário são documentados em [FEATURES.md](../FEATURES.md).
