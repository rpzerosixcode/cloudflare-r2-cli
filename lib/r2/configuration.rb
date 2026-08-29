# frozen_string_literal: true

require_relative "errors"

module R2
    # Configuração centralizada da aplicação.
    #
    # As configurações são obtidas diretamente de variáveis de ambiente,
    # mantendo o MVP simples.
    class Configuration
        attr_reader :access_key_id,
                    :secret_access_key,
                    :endpoint,
                    :bucket,
                    :region

        # Inicializa a configuração a partir das variáveis de ambiente.
        #
        # `R2_REGION` é opcional e, quando ausente, assume o valor padrão
        # `auto`, recomendado para endpoints do Cloudflare R2.
        #
        # @raise [Errors::ConfigurationError] quando alguma variável
        #   obrigatória não está definida
        def initialize
            @access_key_id = fetch_required("R2_ACCESS_KEY_ID")
            @secret_access_key = fetch_required("R2_SECRET_ACCESS_KEY")
            @endpoint = fetch_required("R2_ENDPOINT")
            @bucket = fetch_required("R2_BUCKET")
            @region = ENV.fetch("R2_REGION", "auto")
        end

        private

        # Obtém o valor de uma variável de ambiente obrigatória.
        #
        # @param name [String] nome da variável de ambiente
        # @return [String] valor da variável
        # @raise [Errors::ConfigurationError] se a variável não estiver definida
        def fetch_required(name)
            ENV.fetch(name) do
                raise Errors::ConfigurationError,
                      "Variável de ambiente obrigatória não definida: #{name}"
            end
        end
    end
end
