# frozen_string_literal: true

# Apoio ao controle das variáveis de ambiente R2 nos testes.
module EnvHelper
    R2_ENV_VARS = %w[
        R2_ACCESS_KEY_ID
        R2_SECRET_ACCESS_KEY
        R2_ENDPOINT
        R2_REGION
        R2_BUCKET
    ].freeze

    # Aplica os valores informados às variáveis de ambiente R2, executa o
    # bloco e restaura o estado anterior ao final.
    #
    # Variáveis de ambiente não informadas são removidas durante o bloco,
    # garantindo que nenhuma configuração externa interfira nos testes.
    def with_r2_env(values = {})
        saved = snapshot_env

        clear_env
        apply_env(values)

        yield
    ensure
        restore_env(saved)
    end

    private

    # Guarda os valores atuais das variáveis de ambiente R2.
    def snapshot_env
        R2_ENV_VARS.to_h { |var| [var, ENV.fetch(var, nil)] }
    end

    # Remove as variáveis de ambiente R2 do ambiente.
    def clear_env
        R2_ENV_VARS.each { |var| ENV.delete(var) }
    end

    # Aplica os valores informados às variáveis de ambiente R2.
    def apply_env(values)
        values.each { |var, value| ENV[var] = value }
    end

    # Restaura o estado anterior das variáveis de ambiente R2.
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
