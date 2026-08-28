# frozen_string_literal: true

require "aws-sdk-s3"

module R2
    # Camada de armazenamento responsável pela comunicação com o Cloudflare R2.
    #
    # Utiliza a gem `aws-sdk-s3` com o endpoint compatível com S3 fornecido
    # pela configuração da aplicação.
    class Storage
        # Inicializa o armazenamento com as credenciais e o bucket configurados.
        #
        # @param config [Configuration] configuração da aplicação
        def initialize(config)
            @bucket = config.bucket

            @s3 = Aws::S3::Client.new(
                region: config.region,
                access_key_id: config.access_key_id,
                secret_access_key: config.secret_access_key,
                endpoint: config.endpoint,
                force_path_style: true
            )
        end

        # Envia um objeto para o bucket configurado.
        #
        # Recebe o conteúdo já preparado pela camada que utiliza o armazenamento
        # e o entrega ao Cloudflare R2.
        #
        # @param key [String] chave do objeto no bucket
        # @param body [IO, String] conteúdo do objeto a ser enviado
        # @return [String] etag do objeto enviado
        # @raise [Errors::Error] se a operação falhar
        def upload(key:, body:)
            response = @s3.put_object(
                bucket: @bucket,
                key: key,
                body: body
            )

            response.etag
        rescue StandardError => e
            raise Errors::Error, e.message
        end

        def delete; end

        def list; end
    end
end
