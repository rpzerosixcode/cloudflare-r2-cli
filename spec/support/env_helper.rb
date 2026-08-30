# frozen_string_literal: true

# Support for controlling the R2 environment variables in tests.
module EnvHelper
    R2_ENV_VARS = %w[
        R2_ACCESS_KEY_ID
        R2_SECRET_ACCESS_KEY
        R2_ENDPOINT
        R2_REGION
        R2_BUCKET
    ].freeze

    # Applies the given values to the R2 environment variables, runs the
    # block and restores the previous state at the end.
    #
    # Environment variables not provided are removed during the block,
    # ensuring that no external setting interferes with the tests.
    def with_r2_env(values = {})
        saved = snapshot_env

        clear_env
        apply_env(values)

        yield
    ensure
        restore_env(saved)
    end

    private

    # Saves the current values of the R2 environment variables.
    def snapshot_env
        R2_ENV_VARS.to_h { |var| [var, ENV.fetch(var, nil)] }
    end

    # Removes the R2 environment variables from the environment.
    def clear_env
        R2_ENV_VARS.each { |var| ENV.delete(var) }
    end

    # Applies the given values to the R2 environment variables.
    def apply_env(values)
        values.each { |var, value| ENV[var] = value }
    end

    # Restores the previous state of the R2 environment variables.
    def restore_env(saved)
        saved.each do |var, value|
            if value.nil?
                ENV.delete(var)
            else
                ENV[var] = value
            end
        end
    end
end
