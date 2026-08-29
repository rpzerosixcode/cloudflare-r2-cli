# frozen_string_literal: true

require "base64"
require "fileutils"
require "open3"
require "rbconfig"
require "r2"
require "securerandom"

# Suporte aos testes E2E.
#
# Carrega as variáveis de ambiente do arquivo `.env` e oferece utilitários
# para executar o CLI em um processo separado e preparar os dados dos testes.
module E2EHelper
  ROOT = File.expand_path("../..", __dir__).freeze
  BIN = File.join(ROOT, "bin", "r2").freeze
  ENV_FILE = File.join(ROOT, ".env").freeze
  TEST_BUCKET = ENV.fetch("R2_TEST_BUCKET", "test-bucket").freeze

  # Configuração mínima usada na limpeza dos objetos externos.
  CLEANUP_CONFIG = Struct.new(
    :bucket,
    :region,
    :access_key_id,
    :secret_access_key,
    :endpoint
  )

  REQUIRED_VARS = %w[
    R2_ACCESS_KEY_ID
    R2_SECRET_ACCESS_KEY
    R2_ENDPOINT
  ].freeze

  # Imagem JPEG mínima (1x1) usada como conteúdo dos arquivos de teste.
  JPEG_1X1 = Base64.decode64(
    "/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8U" \
    "HRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/wAALCAABAAEBAREA" \
    "/8QAFAABAAAAAAAAAAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQEA" \
    "AD8AVN//2Q=="
  ).freeze

  # Carrega as variáveis de ambiente do arquivo `.env`, se existir.
  #
  # Variáveis já definidas no ambiente têm prioridade e não são sobrescritas.
  def load_test_env!
    return if @loaded

    @loaded = true
    return unless File.exist?(ENV_FILE)

    File.foreach(ENV_FILE) { |line| apply_env_line(line) }
  end

  # Executa o CLI em um processo separado, como um usuário faria no terminal.
  #
  # O bucket usado pelos testes é sempre o bucket de teste.
  def run_cli(*args, env: {})
    load_test_env!
    ensure_required_env!

    process_env = {
      "R2_ACCESS_KEY_ID" => ENV.fetch("R2_ACCESS_KEY_ID"),
      "R2_SECRET_ACCESS_KEY" => ENV.fetch("R2_SECRET_ACCESS_KEY"),
      "R2_ENDPOINT" => ENV.fetch("R2_ENDPOINT"),
      "R2_REGION" => ENV.fetch("R2_REGION", "auto"),
      "R2_BUCKET" => TEST_BUCKET
    }.merge(env)

    Open3.capture3(
      process_env,
      RbConfig.ruby,
      BIN,
      *args,
      chdir: ROOT
    )
  end

  # Cria um arquivo temporário único para ser enviado nos testes.
  def create_temp_file(prefix: "teste")
    dir = File.join(ROOT, "tmp", "e2e")

    FileUtils.mkdir_p(dir)

    path = File.join(dir, "#{prefix}-#{SecureRandom.hex(4)}.jpg")
    File.binwrite(path, JPEG_1X1)

    tracked_files << path

    path
  end

  # Remove os arquivos temporários criados durante os testes.
  def cleanup_temp_files!
    FileUtils.rm_rf(File.join(ROOT, "tmp", "e2e"))
  end

  # Remove do bucket de testes os objetos enviados durante os testes.
  #
  # Considera que cada arquivo criado por `create_temp_file` é enviado pelo
  # comando `upload`, usando o nome do arquivo como chave do objeto no bucket.
  #
  # A limpeza é tolerante a falhas: erros de rede ou de credenciais apenas
  # registram um aviso, evitando que a limpeza faça um cenário já validado
  # ser marcado como falha.
  def cleanup_external_data!
    keys = tracked_files.map { |path| File.basename(path) }.uniq
    return if keys.empty?

    keys.each { |key| external_storage.delete(key: key) }
  rescue StandardError => e
    warn "Aviso: não foi possível limpar os objetos externos do bucket de testes: #{e.message}"
  ensure
    tracked_files.clear
  end

  # Caminhos dos arquivos criados durante os testes ainda não limpos.
  def tracked_files
    @tracked_files ||= []
  end

  # Armazenamento usado na limpeza dos objetos externos.
  #
  # Sempre direcionado ao bucket de testes, isolado do ambiente de produção.
  def external_storage
    config = CLEANUP_CONFIG.new(
      TEST_BUCKET,
      ENV.fetch("R2_REGION", "auto"),
      ENV.fetch("R2_ACCESS_KEY_ID"),
      ENV.fetch("R2_SECRET_ACCESS_KEY"),
      ENV.fetch("R2_ENDPOINT")
    )

    R2::Storage.new(config)
  end

  # Aplica uma linha do arquivo `.env` ao ambiente, quando válida.
  def apply_env_line(line)
    key, value = line.strip.split("=", 2)

    return if key.nil? || value.nil? || key.empty? || key.start_with?("#")

    ENV[key] = value unless ENV.key?(key)
  end

  # Garante que as variáveis de ambiente necessárias estejam disponíveis.
  def ensure_required_env!
    missing = REQUIRED_VARS.reject { |var| ENV.key?(var) }

    return if missing.empty?

    raise "Variáveis de ambiente necessárias ausentes: #{missing.join(", ")}. " \
          "Defina-as no arquivo .env ou no ambiente."
  end

  module_function :load_test_env!,
                  :run_cli,
                  :create_temp_file,
                  :cleanup_temp_files!,
                  :apply_env_line,
                  :ensure_required_env!
end
