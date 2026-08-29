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
        it "envia o conteúdo para o bucket com a chave informada" do
            expect(client).to receive(:put_object).with(
                bucket: "bucket-teste",
                key: "foto.jpg",
                body: "conteudo"
            )

            storage.upload(key: "foto.jpg", body: "conteudo")
        end

        it "converte falhas do cliente em Errors::Error" do
            allow(client).to receive(:put_object).and_raise(StandardError, "falha de rede")

            expect { storage.upload(key: "foto.jpg", body: "conteudo") }
                .to raise_error(R2::Errors::Error, "falha de rede")
        end
    end

    describe "#delete" do
        it "exclui o objeto do bucket" do
            expect(client).to receive(:delete_object).with(
                bucket: "bucket-teste",
                key: "foto.jpg"
            )

            storage.delete(key: "foto.jpg")
        end

        it "converte falhas do cliente em Errors::Error" do
            allow(client).to receive(:delete_object).and_raise(StandardError, "falha de rede")

            expect { storage.delete(key: "foto.jpg") }
                .to raise_error(R2::Errors::Error, "falha de rede")
        end
    end

    describe "#list" do
        it "retorna as chaves dos objetos armazenados" do
            response = double("resposta", contents: [double("objeto", key: "a.jpg"), double("objeto", key: "b.png")])
            allow(client).to receive(:list_objects_v2).and_return(response)

            expect(storage.list).to eq(%w[a.jpg b.png])
        end

        it "retorna uma lista vazia quando não há objetos" do
            allow(client).to receive(:list_objects_v2).and_return(double("resposta", contents: []))

            expect(storage.list).to eq([])
        end

        it "converte falhas do cliente em Errors::Error" do
            allow(client).to receive(:list_objects_v2).and_raise(StandardError, "falha de rede")

            expect { storage.list }.to raise_error(R2::Errors::Error, "falha de rede")
        end
    end
end
