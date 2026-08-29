# frozen_string_literal: true

require "fileutils"
require "securerandom"

# Apoio à criação e remoção de arquivos temporários dos testes.
module TempFileHelper
    # Diretório exclusivo dos arquivos temporários dos testes em processo.
    #
    # Isolado do diretório usado pelos testes E2E (`tmp/e2e`).
    TEST_TMP_DIR = File.expand_path("../../tmp/spec", __dir__).freeze

    # Cria um arquivo temporário único para ser usado nos testes.
    #
    # Os arquivos ficam restritos a `tmp/spec/`, conforme as diretrizes do
    # projeto, e são removidos automaticamente após cada exemplo.
    #
    # @param prefix [String] prefixo do nome do arquivo
    # @param content [String] conteúdo do arquivo
    # @return [String] caminho do arquivo criado
    def create_temp_file(prefix: "teste", content: "conteudo de teste")
        FileUtils.mkdir_p(TEST_TMP_DIR)

        path = File.join(TEST_TMP_DIR, "#{prefix}-#{SecureRandom.hex(4)}.jpg")
        File.binwrite(path, content)

        path
    end

    # Remove os arquivos temporários criados durante os testes.
    def cleanup_temp_files!
        FileUtils.rm_rf(TEST_TMP_DIR)
    end

    module_function :create_temp_file, :cleanup_temp_files!
end
