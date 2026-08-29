# frozen_string_literal: true

require "spec_helper"
require "r2"
require "tmpdir"

RSpec.describe R2::CLI do
    include CliExpectations
    include TempFileHelper

    let(:configuration) { instance_double(R2::Configuration) }
    let(:storage) { instance_double(R2::Storage) }

    subject(:cli) { described_class.new([], configuration: configuration, storage: storage) }

    describe ".exit_on_failure?" do
        it "retorna true para encerrar com código de status diferente de zero" do
            expect(described_class.exit_on_failure?).to be(true)
        end
    end

    describe "#upload" do
        let(:file) { create_temp_file(prefix: "upload") }
        let(:key) { File.basename(file) }

        context "em caso de sucesso" do
            it "envia o arquivo usando o nome do arquivo como chave do objeto" do
                expect(storage).to receive(:upload).with(key: key, body: instance_of(File))

                expect { cli.upload(file) }
                    .to output("Imagem enviada com sucesso: #{key}\n").to_stdout
            end
        end

        context "quando o arquivo não existe" do
            it "exibe o erro e encerra com código de status 1" do
                expect(cli).to receive(:warn).with("Erro: Arquivo não encontrado: inexistente.jpg")

                expect_cli_to_exit(1) { cli.upload("inexistente.jpg") }
            end
        end

        context "quando o caminho informado é um diretório" do
            it "exibe o erro e encerra com código de status 1" do
                Dir.mktmpdir do |directory|
                    expect(cli).to receive(:warn)
                        .with("Erro: O caminho informado não é um arquivo: #{directory}")

                    expect_cli_to_exit(1) { cli.upload(directory) }
                end
            end
        end

        context "quando o armazenamento falha" do
            it "exibe o erro e encerra com código de status 1" do
                allow(storage).to receive(:upload).and_raise(R2::Errors::Error, "bucket inválido")

                expect(cli).to receive(:warn).with("Erro: bucket inválido")

                expect_cli_to_exit(1) { cli.upload(file) }
            end
        end
    end

    describe "#delete" do
        context "em caso de sucesso" do
            it "exclui o arquivo do armazenamento" do
                expect(storage).to receive(:delete).with(key: "foto.jpg")

                expect { cli.delete("foto.jpg") }
                    .to output("Arquivo excluído com sucesso: foto.jpg\n").to_stdout
            end
        end

        context "quando o armazenamento falha" do
            it "exibe o erro e encerra com código de status 1" do
                allow(storage).to receive(:delete).and_raise(R2::Errors::Error, "bucket inválido")

                expect(cli).to receive(:warn).with("Erro: bucket inválido")

                expect_cli_to_exit(1) { cli.delete("foto.jpg") }
            end
        end
    end

    describe "#list" do
        context "quando existem objetos" do
            it "exibe cada objeto em uma linha" do
                allow(storage).to receive(:list).and_return(%w[a.jpg b.png])

                expect { cli.list }.to output("a.jpg\nb.png\n").to_stdout
            end
        end

        context "quando não existem objetos" do
            it "não exibe nada" do
                allow(storage).to receive(:list).and_return([])

                expect { cli.list }.not_to output.to_stdout
            end
        end

        context "quando o armazenamento falha" do
            it "exibe o erro e encerra com código de status 1" do
                allow(storage).to receive(:list).and_raise(R2::Errors::Error, "bucket inválido")

                expect(cli).to receive(:warn).with("Erro: bucket inválido")

                expect_cli_to_exit(1) { cli.list }
            end
        end
    end
end
