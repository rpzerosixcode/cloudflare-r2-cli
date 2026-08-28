# frozen_string_literal: true

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
        # Lança `KeyError` quando alguma das variáveis obrigatórias não estiver
        # definida.
        def initialize
            @access_key_id = ENV.fetch("R2_ACCESS_KEY_ID")
            @secret_access_key = ENV.fetch("R2_SECRET_ACCESS_KEY")
            @endpoint = ENV.fetch("R2_ENDPOINT")
            @bucket = ENV.fetch("R2_BUCKET")
            @region = ENV.fetch("R2_REGION", "auto")
        end
    end
end
