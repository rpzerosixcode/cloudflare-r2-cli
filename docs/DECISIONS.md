# Decisões

*>* **Nota:** Decisões técnicas específicas de implementação e código não serão abordadas neste documento. Esses assuntos serão registrados e acompanhados em arquivos específicos, conforme a evolução do projeto.

## Nome

O nome do projeto para publicação será **`cloudflare-r2-cli`**.

Para uso comum e desenvolvimento interno, será utilizado **`r2`**.

## Conteúdo

O projeto será desenvolvido inicialmente em **português**.

Antes do fechamento da versão **`1.0.0`**, o conteúdo do projeto será traduzido e padronizado para **inglês**.

## Changelog

Não será mantido um `CHANGELOG` antes da versão **`1.0.0`**.

A manutenção formal do changelog será iniciada a partir da versão **`1.0.0`**.

## Escopo do MVP

O MVP terá como foco:

* estabelecer uma **base sustentável para evolução**;
* aplicar **boas práticas de desenvolvimento**;
* implementar as **funcionalidades mínimas necessárias**.

**Segurança e otimização não serão objetivos prioritários do MVP**, mas poderão ser consideradas conforme a evolução e as necessidades do projeto.

## Versionamento

O versionamento formal **não será adotado durante o desenvolvimento do MVP**.

A adoção do versionamento será iniciada a partir da versão **`1.0.0`**.

## Injeção de Dependências

As dependências dos componentes devem ser fornecidas preferencialmente por **injeção de dependência**, evitando acoplamento desnecessário às implementações.

A aplicação não utilizará um container de injeção de dependências inicialmente. As dependências serão fornecidas diretamente pelos componentes que as utilizam.

O uso de um container poderá ser **reavaliado futuramente**, caso o crescimento da aplicação torne sua adoção justificável.

