# frozen_string_literal: true

module R2
    # Centralização dos erros do projeto.
    module Errors
        # Erro padrão do projeto.
        #
        # No MVP, as exceções específicas das implementações são abstraídas
        # para esta classe, padronizando o tratamento e evitando expor detalhes
        # das implementações.
        class Error < StandardError
        end
    end
end
