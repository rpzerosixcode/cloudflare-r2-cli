# frozen_string_literal: true

# Expectations about the CLI termination.
module CliExpectations
    # Expects the block to terminate the CLI with the given status code.
    def expect_cli_to_exit(status, &)
        expect(&)
            .to raise_error(SystemExit) { |error| expect(error.status).to eq(status) }
    end
end
