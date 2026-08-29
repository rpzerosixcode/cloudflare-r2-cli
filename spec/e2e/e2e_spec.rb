# frozen_string_literal: true

RSpec.describe "R2 CLI", type: :e2e do
    include E2EHelper

    after do
        cleanup_temp_files!
        cleanup_external_data!
    end

    describe "upload" do
        it "envia um arquivo para o bucket de teste" do
            file = create_temp_file
            key = File.basename(file)

            stdout, stderr, status = run_cli("upload", file)

            expect(status).to be_success
            expect(stderr).to be_empty
            expect(stdout).to include("Imagem enviada com sucesso: #{key}")
        end
    end

    describe "list" do
        it "lista os objetos armazenados no bucket" do
            file = create_temp_file
            key = File.basename(file)

            run_cli("upload", file)

            stdout, stderr, status = run_cli("list")

            expect(status).to be_success
            expect(stderr).to be_empty
            expect(stdout).to include(key)
        end
    end

    describe "delete" do
        it "remove um objeto armazenado no bucket" do
            file = create_temp_file
            key = File.basename(file)

            run_cli("upload", file)

            stdout, stderr, status = run_cli("delete", key)

            expect(status).to be_success
            expect(stderr).to be_empty
            expect(stdout).to include("Arquivo excluído com sucesso: #{key}")
        end
    end
end
