# frozen_string_literal: true

require "spec_helper"
require "r2"

RSpec.describe "CLI integrada ao armazenamento", type: :integration do
    include CliRunner
    include TempFileHelper

    let(:client) { FakeS3Client.new }

    before do
        allow(Aws::S3::Client).to receive(:new).and_return(client)
    end

    describe "upload" do
        let(:file) { create_temp_file(prefix: "upload") }
        let(:key) { File.basename(file) }

        context "em caso de sucesso" do
            it "envia um arquivo para o bucket e usa o nome do arquivo como chave" do
                expect { run_cli("upload", file) }
                    .to output("Imagem enviada com sucesso: #{key}\n").to_stdout

                expect(client.uploads.size).to eq(1)
                expect(client.uploads.first[:bucket]).to eq("bucket-integracao")
                expect(client.uploads.first[:key]).to eq(key)
                expect(client.uploads.first[:body]).to be_a(File)
            end
        end

        context "quando o arquivo não existe" do
            it "exibe o erro e encerra com código de status 1" do
                nonexistent = File.join("tmp", "spec", "inexistente.jpg")

                run_cli_and_expect_failure(
                    "upload",
                    nonexistent,
                    message: "Arquivo não encontrado: #{nonexistent}"
                )
            end
        end

        context "quando o armazenamento falha" do
            it "exibe o erro e encerra com código de status 1" do
                client.fail_on(:upload)

                run_cli_and_expect_failure("upload", file, message: "simulacao de falha")

                expect(client.uploads).to be_empty
            end
        end
    end

    describe "list" do
        context "quando existem objetos" do
            let(:client) { FakeS3Client.new(objects: %w[a.jpg b.png]) }

            it "lista os objetos armazenados no bucket" do
                expect { run_cli("list") }
                    .to output("a.jpg\nb.png\n").to_stdout
            end
        end

        context "quando não existem objetos" do
            it "não exibe nada" do
                expect { run_cli("list") }.not_to output.to_stdout
            end
        end

        context "quando o armazenamento falha" do
            it "exibe o erro e encerra com código de status 1" do
                client.fail_on(:list)

                run_cli_and_expect_failure("list", message: "simulacao de falha")
            end
        end
    end

    describe "delete" do
        context "em caso de sucesso" do
            it "exclui o objeto do bucket" do
                expect { run_cli("delete", "foto.jpg") }
                    .to output("Arquivo excluído com sucesso: foto.jpg\n").to_stdout

                expect(client.deletes.size).to eq(1)
                expect(client.deletes.first[:bucket]).to eq("bucket-integracao")
                expect(client.deletes.first[:key]).to eq("foto.jpg")
            end
        end

        context "quando o armazenamento falha" do
            it "exibe o erro e encerra com código de status 1" do
                client.fail_on(:delete)

                run_cli_and_expect_failure("delete", "foto.jpg", message: "simulacao de falha")
            end
        end
    end

    describe "ciclo completo" do
        it "realiza upload, list e delete em conjunto" do
            file = create_temp_file(prefix: "ciclo")
            key = File.basename(file)

            expect { run_cli("upload", file) }
                .to output("Imagem enviada com sucesso: #{key}\n").to_stdout

            expect { run_cli("list") }
                .to output(/#{Regexp.escape(key)}/).to_stdout

            expect { run_cli("delete", key) }
                .to output("Arquivo excluído com sucesso: #{key}\n").to_stdout

            expect { run_cli("list") }
                .to output("").to_stdout
        end
    end
end
