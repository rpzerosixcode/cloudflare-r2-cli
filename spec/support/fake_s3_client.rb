# frozen_string_literal: true

# Cliente S3 falso usado nos testes de integração.
#
# Simula um bucket isolado em memória e registra as chamadas realizadas,
# permitindo validar a interação entre a CLI, o armazenamento e o cliente
# do Cloudflare R2 sem depender de uma conexão real.
class FakeS3Client
    # Resposta da operação de listagem de objetos.
    ObjectList = Struct.new(:contents)

    # Resumo de um objeto armazenado no bucket.
    # Listagem: https://docs.aws.amazon.com/AmazonS3/latest/API/API_Object.html
    ObjectSummary = Struct.new(:key)

    # Erro levantado quando um cenário de falha é configurado.
    Failure = Class.new(StandardError)

    attr_reader :uploads, :deletes, :last_list_bucket

    # @param objects [Array<String>] chaves dos objetos já presentes no bucket
    def initialize(objects: [])
        @objects = objects.dup
        @uploads = []
        @deletes = []
        @failures = {}
    end

    # Configura um cenário de falha para uma operação específica.
    #
    # @param operation [Symbol] operação que deve falhar (:upload, :delete, :list)
    # @param message [String] mensagem do erro simulado
    def fail_on(operation, message: "simulacao de falha")
        @failures[operation] = message
    end

    # Simula a criação de um objeto no bucket.
    def put_object(bucket:, key:, body:)
        raise_failure!(:upload)

        @uploads << { bucket: bucket, key: key, body: body }
        @objects << key

        nil
    end

    # Simula a exclusão de um objeto do bucket.
    def delete_object(bucket:, key:)
        raise_failure!(:delete)

        @deletes << { bucket: bucket, key: key }
        @objects.delete(key)

        nil
    end

    # Simula a listagem dos objetos do bucket.
    def list_objects_v2(bucket:)
        raise_failure!(:list)

        @last_list_bucket = bucket
        ObjectList.new(@objects.map { |key| ObjectSummary.new(key) })
    end

    private

    # Levanta um erro simulado quando um cenário de falha está configurado.
    def raise_failure!(operation)
        message = @failures[operation]

        raise Failure, message if message
    end
end
