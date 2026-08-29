# frozen_string_literal: true

module R2
    # Centralização dos erros do projeto.
    module Errors
        # Erro base do projeto.
        #
        # Todos os erros de domínio herdam desta classe, permitindo que
        # consumidores capturem o erro genérico quando não precisam
        # distinguir a causa, ou um erro específico quando precisam.
        class Error < StandardError
        end

        # Configuração obrigatória ausente ou inválida.
        class ConfigurationError < Error
        end

        # O arquivo informado não existe.
        class FileNotFoundError < Error
        end

        # O caminho informado não corresponde a um arquivo.
        class InvalidFileError < Error
        end

        # Sem permissão para ler o arquivo informado.
        class PermissionError < Error
        end

        # O bucket configurado não existe.
        class BucketNotFoundError < Error
        end

        # Falha de rede ao comunicar com o Cloudflare R2.
        class NetworkError < Error
        end

        # Falha não classificada na camada de armazenamento.
        class StorageError < Error
        end
    end
end
