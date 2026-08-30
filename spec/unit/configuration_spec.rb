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
            "R2_BUCKET" => "test-bucket"
        }
    end

    describe "#initialize" do
        context "when all required variables are defined" do
            it "loads the configuration from the environment" do
                with_r2_env(valid_env) do
                    config = described_class.new

                    expect(config.access_key_id).to eq("access-key-id")
                    expect(config.secret_access_key).to eq("secret-access-key")
                    expect(config.endpoint).to eq("https://s3.example.com")
                    expect(config.bucket).to eq("test-bucket")
                end
            end
        end

        context "region" do
            it "uses the default 'auto' when R2_REGION is not defined" do
                with_r2_env(valid_env) do
                    expect(described_class.new.region).to eq("auto")
                end
            end

            it "uses the value defined in R2_REGION" do
                with_r2_env(valid_env.merge("R2_REGION" => "us-east-1")) do
                    expect(described_class.new.region).to eq("us-east-1")
                end
            end
        end

        context "when a required variable is missing" do
            %w[R2_ACCESS_KEY_ID R2_SECRET_ACCESS_KEY R2_ENDPOINT R2_BUCKET].each do |variable|
                it "raises Errors::ConfigurationError when #{variable} is not defined" do
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
