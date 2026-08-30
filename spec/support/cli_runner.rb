# frozen_string_literal: true

require "r2"
require_relative "cli_expectations"
require_relative "env_helper"
require_relative "output_capture"

# Full CLI execution in integration tests.
#
# Composes the required support modules to run the CLI with a controlled
# environment and validate its outputs.
module CliRunner
    include CliExpectations
    include EnvHelper
    include OutputCapture

    # Default environment used in tests with the CLI.
    DEFAULT_TEST_ENV = {
        "R2_ACCESS_KEY_ID" => "access-key-id",
        "R2_SECRET_ACCESS_KEY" => "secret-access-key",
        "R2_ENDPOINT" => "https://s3.example.com",
        "R2_REGION" => "auto",
        "R2_BUCKET" => "integration-bucket"
    }.freeze

    # Runs the CLI as a user would, with the given environment.
    #
    # The R2 environment variables are applied only during the execution and
    # restored at the end, not interfering with the other tests.
    def run_cli(*args, env: DEFAULT_TEST_ENV)
        with_r2_env(env) { R2::CLI.start(args) }
    end

    # Runs the CLI expecting termination with an error (status code 1) and
    # ensures that the expected error message is shown on the error output.
    def run_cli_and_expect_failure(*args, message:, env: DEFAULT_TEST_ENV)
        expect_cli_to_exit(1) { capture_stderr { run_cli(*args, env: env) } }

        expect(last_stderr).to include("Error: #{message}")
    end
end
