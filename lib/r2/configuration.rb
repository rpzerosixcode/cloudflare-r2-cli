# frozen_string_literal: true

require_relative "errors"

module R2
    # Centralized application configuration.
    #
    # Settings are read directly from environment variables.
    class Configuration
        attr_reader :access_key_id,
                    :secret_access_key,
                    :endpoint,
                    :bucket,
                    :region

        # Initializes the configuration from environment variables.
        #
        # `R2_REGION` is optional and defaults to `auto` when absent, which
        # is recommended for Cloudflare R2 endpoints.
        #
        # @raise [Errors::ConfigurationError] when any required variable
        #   is not defined
        def initialize
            @access_key_id = fetch_required("R2_ACCESS_KEY_ID")
            @secret_access_key = fetch_required("R2_SECRET_ACCESS_KEY")
            @endpoint = fetch_required("R2_ENDPOINT")
            @bucket = fetch_required("R2_BUCKET")
            @region = ENV.fetch("R2_REGION", "auto")
        end

        private

        # Gets the value of a required environment variable.
        #
        # @param name [String] name of the environment variable
        # @return [String] variable value
        # @raise [Errors::ConfigurationError] if the variable is not defined
        def fetch_required(name)
            ENV.fetch(name) do
                raise Errors::ConfigurationError,
                      "Required environment variable not defined: #{name}"
            end
        end
    end
end
