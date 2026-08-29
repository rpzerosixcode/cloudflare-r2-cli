# frozen_string_literal: true

require "thor"
require_relative "errors"

module R2
    # Interface de linha de comando do projeto.
    #
    # Atua como um orquestrador mínimo: interpreta as entradas do usuário,
    # delega a execução aos componentes responsáveis e apresenta os resultados.
    class CLI < Thor
        # Inicializa a CLI com suas dependências.
        #
        # @param configuration [Configuration] configuração da aplicação
        # @param storage [Storage] armazenamento usado nas operações com objetos
        def initialize(
            *args,
            configuration: Configuration.new,
            storage: Storage.new(configuration)
        )
            super(*args)
            @configuration = configuration
            @storage = storage
        end

        # Garante que o Thor encerre com código de status diferente de zero
        # quando uma operação falhar.
        def self.exit_on_failure?
            true
        end

        # Inicia a CLI e apresenta de forma clara erros de domínio não
        # tratados pelos comandos.
        #
        # Erros lançados antes da execução de um comando (como configuração
        # ausente) são capturados aqui, exibidos na saída de erro e encerram a
        # CLI com código de status 1, evitando rastreamentos de pilha.
        def self.start(*args)
            super
        rescue Errors::Error => e
            warn "Erro: #{e.message}"
            exit 1
        end

        desc "upload ARQUIVO", "Envia uma imagem para o R2"

        long_desc <<~LONGDESC
            Envia uma imagem para o bucket do Cloudflare R2 configurado.
            A chave do objeto no bucket será o nome do arquivo informado.

            Exemplos:

              $ r2 upload imagem.jpg

              $ r2 upload ./imagens/foto.png
        LONGDESC

        # Envia uma imagem para o bucket do Cloudflare R2 configurado.
        #
        # A chave do objeto no bucket será o nome do arquivo informado.
        #
        # @param file [String] caminho do arquivo a ser enviado
        def upload(file)
            body = open_file(file)
            storage.upload(key: File.basename(file), body: body)
            puts "Imagem enviada com sucesso: #{File.basename(file)}"
        rescue Errors::Error => e
            warn "Erro: #{e.message}"
            exit 1
        ensure
            body&.close
        end

        desc "delete ARQUIVO", "Exclui um arquivo do R2"

        long_desc <<~LONGDESC
            Exclui um arquivo do bucket do Cloudflare R2 configurado.

            Exemplos:

              $ r2 delete imagem.jpg
        LONGDESC

        # Exclui um arquivo do bucket do Cloudflare R2 configurado.
        #
        # A operação é considerada bem-sucedida quando o armazenamento
        # conclui a solicitação sem erro.
        #
        # @param file [String] nome do arquivo a ser excluído
        def delete(file)
            storage.delete(key: file)
            puts "Arquivo excluído com sucesso: #{file}"
        rescue Errors::Error => e
            warn "Erro: #{e.message}"
            exit 1
        end

        desc "list", "Lista os arquivos armazenados no R2"

        long_desc <<~LONGDESC
            Lista os arquivos armazenados no bucket do Cloudflare R2 configurado.

            Exemplos:

              $ r2 list
        LONGDESC

        # Lista os arquivos armazenados no bucket do Cloudflare R2 configurado.
        #
        # No MVP, não há paginação ou controle da quantidade de objetos retornados.
        def list
            files = storage.list

            files.each do |file|
                puts file
            end
        rescue Errors::Error => e
            warn "Erro: #{e.message}"
            exit 1
        end

        private

        # Abre o arquivo informado para leitura.
        #
        # O arquivo precisa permanecer aberto durante o envio, por isso não é
        # usado o modo com bloco; o fechamento é garantido no `ensure` do
        # comando `upload`.
        #
        # @param file [String] caminho do arquivo
        # @return [File] arquivo aberto no modo de leitura binária
        # @raise [Errors::FileNotFoundError] se o arquivo não existir
        # @raise [Errors::InvalidFileError] se o caminho não for um arquivo
        # @raise [Errors::PermissionError] se o arquivo não puder ser lido
        def open_file(file)
            raise Errors::FileNotFoundError, "Arquivo não encontrado: #{file}" unless File.exist?(file)
            raise Errors::InvalidFileError, "O caminho informado não é um arquivo: #{file}" unless File.file?(file)
            raise Errors::PermissionError, "Sem permissão para ler o arquivo: #{file}" unless File.readable?(file)

            File.open(file, "rb")
        rescue Errno::EACCES, Errno::EPERM
            raise Errors::PermissionError, "Sem permissão para ler o arquivo: #{file}"
        end

        attr_reader :configuration, :storage
    end
end
