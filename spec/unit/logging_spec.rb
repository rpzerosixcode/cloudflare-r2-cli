# frozen_string_literal: true

require "spec_helper"
require "r2/logging"

RSpec.describe R2::Logging do
    describe ".build" do
        it "writes debug messages to the given output when verbose" do
            output = StringIO.new
            logger = described_class.build(verbose: true, output: output)

            logger.debug("detailed message")

            expect(output.string).to include("detailed message\n")
        end

        it "returns a null logger ignoring messages when not verbose" do
            logger = described_class.build(verbose: false)

            expect(logger).to be_a(R2::Logging::NullLogger)
            expect { logger.debug("detailed message") }.not_to raise_error
        end
    end

    describe R2::Logging::NullLogger do
        it "ignores debug messages" do
            expect { subject.debug("detailed message") }.not_to raise_error
        end
    end
end
