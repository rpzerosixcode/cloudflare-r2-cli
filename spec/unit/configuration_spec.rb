# frozen_string_literal: true

require "spec_helper"
require "r2/configuration"

RSpec.describe R2::Configuration do
    include EnvHelper

    let(:valid_env) do
        {
            "R2_ACCESS_KEY_ID" => "access-key-id",
            "R2_SECRET_ACCESS_KEY" => "secret-access-key",
            "R2_ENDPOINT" => "https://s3.example.com",
            "R2_BUCKET" => "bucket-teste"
        }
    end

    describe "#initialize" do
        context "quando todas as variáveis obrigatórias estão definidas" do
            it "carrega as configurações a partir do ambiente" do
                with_r2_env(valid_env) do
                    config = described_class.new

                    expect(config.access_key_id).to eq("access-key-id")
                    expect(config.secret_access_key).to eq("secret-access-key")
                    expect(config.endpoint).to eq("https://s3.example.com")
                    expect(config.bucket).to eq("bucket-teste")
                end
            end
        end

        context "região" do
            it "usa o padrão 'auto' quando R2_REGION não está definida" do
                with_r2_env(valid_env) do
                    expect(described_class.new.region).to eq("auto")
                end
            end

            it "usa o valor definido em R2_REGION" do
                with_r2_env(valid_env.merge("R2_REGION" => "us-east-1")) do
                    expect(described_class.new.region).to eq("us-east-1")
                end
            end
        end

        context "quando uma variável obrigatória está ausente" do
            %w[R2_ACCESS_KEY_ID R2_SECRET_ACCESS_KEY R2_ENDPOINT R2_BUCKET].each do |variable|
                it "levanta Errors::ConfigurationError quando #{variable} não está definida" do
                    with_r2_env(valid_env.reject { |key, _value| key == variable }) do
                        expect { described_class.new }
                            .to raise_error(
                                R2::Errors::ConfigurationError,
                                /#{Regexp.escape(variable)}/
                            )
                    end
                end
            end
        end
    end
end
