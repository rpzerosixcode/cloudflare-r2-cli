# frozen_string_literal: true

require "spec_helper"
require "r2/storage"

RSpec.describe R2::Storage do
    let(:config) do
        instance_double(
            R2::Configuration,
            bucket: "bucket-teste",
            region: "auto",
            access_key_id: "access-key-id",
            secret_access_key: "secret-access-key",
            endpoint: "https://s3.example.com"
        )
    end

    let(:client) { instance_double(Aws::S3::Client) }

    subject(:storage) { described_class.new(config) }

    before do
        allow(Aws::S3::Client).to receive(:new).and_return(client)
    end

    shared_examples "conversão de falhas do cliente para erros de domínio" do
        it "converte falhas de credenciais em ConfigurationError" do
            allow(client).to receive(operation).and_raise(Aws::Errors::MissingCredentialsError)

            expect { perform }
                .to raise_error(R2::Errors::ConfigurationError, /credenciais/)
        end

        it "converte bucket inexistente em BucketNotFoundError" do
            allow(client).to receive(operation)
                .and_raise(Aws::S3::Errors::NoSuchBucket.new(nil, "bucket não existe"))

            expect { perform }
                .to raise_error(R2::Errors::BucketNotFoundError, "Bucket não encontrado: bucket-teste")
        end

        it "converte falhas de rede em NetworkError" do
            allow(client).to receive(operation)
                .and_raise(Seahorse::Client::NetworkingError.new(StandardError.new("falha de rede")))

            expect { perform }
                .to raise_error(R2::Errors::NetworkError, "falha de rede")
        end

        it "converte falhas genéricas em StorageError preservando a mensagem" do
            allow(client).to receive(operation).and_raise(StandardError, "falha de rede")

            expect { perform }
                .to raise_error(R2::Errors::StorageError, "falha de rede")
        end
    end

    describe "#initialize" do
        it "cria o cliente S3 com as configurações fornecidas" do
            expect(Aws::S3::Client).to receive(:new).with(
                region: "auto",
                access_key_id: "access-key-id",
                secret_access_key: "secret-access-key",
                endpoint: "https://s3.example.com",
                force_path_style: true
            )

            storage
        end
    end

    describe "#upload" do
        let(:operation) { :put_object }
        let(:perform) { storage.upload(key: "foto.jpg", body: "conteudo") }

        it "envia o conteúdo para o bucket com a chave informada" do
            expect(client).to receive(:put_object).with(
                bucket: "bucket-teste",
                key: "foto.jpg",
                body: "conteudo"
            )

            perform
        end

        it_behaves_like "conversão de falhas do cliente para erros de domínio"
    end

    describe "#delete" do
        let(:operation) { :delete_object }
        let(:perform) { storage.delete(key: "foto.jpg") }

        it "exclui o objeto do bucket" do
            expect(client).to receive(:delete_object).with(
                bucket: "bucket-teste",
                key: "foto.jpg"
            )

            perform
        end

        it_behaves_like "conversão de falhas do cliente para erros de domínio"
    end

    describe "#list" do
        let(:operation) { :list_objects_v2 }
        let(:perform) { storage.list }

        it "retorna as chaves dos objetos armazenados" do
            response = double("resposta", contents: [double("objeto", key: "a.jpg"), double("objeto", key: "b.png")])
            allow(client).to receive(:list_objects_v2).and_return(response)

            expect(storage.list).to eq(%w[a.jpg b.png])
        end

        it "retorna uma lista vazia quando não há objetos" do
            allow(client).to receive(:list_objects_v2).and_return(double("resposta", contents: []))

            expect(storage.list).to eq([])
        end

        it_behaves_like "conversão de falhas do cliente para erros de domínio"
    end
end
