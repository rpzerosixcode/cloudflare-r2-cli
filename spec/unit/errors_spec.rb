# frozen_string_literal: true

require "spec_helper"
require "r2/errors"

RSpec.describe R2::Errors::Error do
    it "is a subclass of StandardError" do
        expect(described_class.superclass).to eq(StandardError)
    end

    it "can be raised with a message" do
        expect { raise described_class, "error message" }
            .to raise_error(described_class, "error message")
    end
end
