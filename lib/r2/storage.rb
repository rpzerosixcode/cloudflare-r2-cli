# frozen_string_literal: true

require "aws-sdk-s3"
require_relative "errors"

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
        # @raise [Errors::Error] se a operação falhar
        def upload(key:, body:)
            @s3.put_object(
                bucket: @bucket,
                key: key,
                body: body
            )
        rescue StandardError => e
            raise_storage_error(e)
        end

        # Exclui um objeto do bucket configurado.
        #
        # A operação é considerada bem-sucedida quando o Cloudflare R2
        # conclui a solicitação sem lançar um erro.
        #
        # @param key [String] chave do objeto no bucket
        # @raise [Errors::Error] se a operação falhar
        def delete(key:)
            @s3.delete_object(
                bucket: @bucket,
                key: key
            )
        rescue StandardError => e
            raise_storage_error(e)
        end

        # Lista os objetos armazenados no bucket configurado.
        #
        # @return [Array<String>] chaves dos objetos armazenados
        # @raise [Errors::Error] se a operação falhar
        def list
            response = @s3.list_objects_v2(bucket: @bucket)
            response.contents.map(&:key)
        rescue StandardError => e
            raise_storage_error(e)
        end

        private

        # Converte erros da camada de armazenamento em erros de domínio do
        # projeto, evitando expor detalhes internos das implementações.
        #
        # A mensagem original é preservada quando útil.
        #
        # @param error [StandardError] erro original
        # @raise [Errors::Error] subclasse correspondente à causa do erro
        def raise_storage_error(error)
            case error
            when Aws::Errors::MissingCredentialsError
                raise Errors::ConfigurationError,
                      "Variáveis de ambiente de credenciais ausentes ou inválidas."
            when Aws::S3::Errors::NoSuchBucket
                raise Errors::BucketNotFoundError, "Bucket não encontrado: #{@bucket}"
            when Seahorse::Client::NetworkingError
                raise Errors::NetworkError, error.message
            else
                raise Errors::StorageError, error.message
            end
        end
    end
end
