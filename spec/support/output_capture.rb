# frozen_string_literal: true

require "stringio"

# Captura das saídas padrão e de erro durante a execução dos testes.
#
# A captura é restaurada mesmo quando o bloco levanta uma exceção,
# como o encerramento da CLI via `SystemExit`.
module OutputCapture
    # Captura a saída padrão durante a execução do bloco.
    #
    # O conteúdo capturado pode ser consultado por `last_stdout`.
    def capture_stdout
        original = $stdout
        @captured_stdout = StringIO.new
        $stdout = @captured_stdout

        yield
    ensure
        $stdout = original
    end

    # Captura a saída de erro durante a execução do bloco.
    #
    # O conteúdo capturado pode ser consultado por `last_stderr`.
    def capture_stderr
        original = $stderr
        @captured_stderr = StringIO.new
        $stderr = @captured_stderr

        yield
    ensure
        $stderr = original
    end

    # Retorna o conteúdo da última captura da saída padrão.
    def last_stdout
        @captured_stdout.string
    end

    # Retorna o conteúdo da última captura da saída de erro.
    def last_stderr
        @captured_stderr.string
    end
end
