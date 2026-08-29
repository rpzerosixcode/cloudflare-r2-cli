# frozen_string_literal: true

# Limpezas automáticas do ambiente de testes.
#
# Garantem que os exemplos não interfiram entre si por causa de resíduos
# de execuções anteriores.
RSpec.configure do |config|
    # Remove resíduos de execuções anteriores antes de iniciar a suíte.
    config.before(:suite) do
        TempFileHelper.cleanup_temp_files!
    end

    # Remove os arquivos temporários criados durante cada exemplo,
    # independentemente do resultado do exemplo.
    config.after(:each) do
        TempFileHelper.cleanup_temp_files!
    end
end
