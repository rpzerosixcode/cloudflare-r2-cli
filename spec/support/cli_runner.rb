# frozen_string_literal: true

require "r2"
require_relative "cli_expectations"
require_relative "env_helper"
require_relative "output_capture"

# Execução da CLI completa nos testes de integração.
#
# Compõe os módulos de apoio necessários para executar a CLI com um
# ambiente controlado e validar suas saídas.
module CliRunner
    include CliExpectations
    include EnvHelper
    include OutputCapture

    # Ambiente padrão utilizado nos testes com a CLI.
    DEFAULT_TEST_ENV = {
        "R2_ACCESS_KEY_ID" => "access-key-id",
        "R2_SECRET_ACCESS_KEY" => "secret-access-key",
        "R2_ENDPOINT" => "https://s3.example.com",
        "R2_REGION" => "auto",
        "R2_BUCKET" => "bucket-integracao"
    }.freeze

    # Executa a CLI como um usuário faria, com o ambiente informado.
    #
    # As variáveis de ambiente R2 são aplicadas apenas durante a execução
    # e restauradas ao final, não interferindo nos demais testes.
    def run_cli(*args, env: DEFAULT_TEST_ENV)
        with_r2_env(env) { R2::CLI.start(args) }
    end

    # Executa a CLI esperando encerramento com erro (código 1) e garante
    # que a mensagem de erro esperada seja exibida na saída de erro.
    def run_cli_and_expect_failure(*args, message:, env: DEFAULT_TEST_ENV)
        expect_cli_to_exit(1) { capture_stderr { run_cli(*args, env: env) } }

        expect(last_stderr).to include("Erro: #{message}")
    end
end
