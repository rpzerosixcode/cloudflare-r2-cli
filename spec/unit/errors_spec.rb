# frozen_string_literal: true

require "spec_helper"
require "r2/errors"

RSpec.describe R2::Errors::Error do
    it "é uma subclasse de StandardError" do
        expect(described_class.superclass).to eq(StandardError)
    end

    it "pode ser levantada com uma mensagem" do
        expect { raise described_class, "mensagem de erro" }
            .to raise_error(described_class, "mensagem de erro")
    end
end
