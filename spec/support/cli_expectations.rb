# frozen_string_literal: true

# Expectativas sobre o encerramento da CLI.
module CliExpectations
    # Espera que o bloco encerre a CLI com o código de status informado.
    def expect_cli_to_exit(status, &block)
        expect(&block)
            .to raise_error(SystemExit) { |error| expect(error.status).to eq(status) }
    end
end
