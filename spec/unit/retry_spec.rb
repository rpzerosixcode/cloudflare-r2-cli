# frozen_string_literal: true

require "spec_helper"
require "r2/logging"
require "r2/retry"

RSpec.describe R2::Retry do
    let(:transient_error) { Class.new(StandardError) }
    let(:sleeps) { [] }
    let(:sleeper) { ->(seconds) { sleeps << seconds } }
    let(:log_output) { StringIO.new }
    let(:logger) { R2::Logging.build(verbose: true, output: log_output) }
    let(:options) do
        {
            policy: R2::Retry::Policy.new(max_attempts: 3, base_delay: 0.5),
            retry_on: [transient_error],
            logger: logger,
            sleeper: sleeper,
            description: "upload of photo.jpg"
        }
    end

    describe R2::Retry::Policy do
        subject(:policy) { described_class.new }

        it "uses the project defaults" do
            expect(policy.max_attempts).to eq(3)
            expect(policy.base_delay).to eq(0.5)
            expect(policy.max_delay).to eq(5.0)
        end

        describe "#delay_for" do
            it "grows exponentially from the base delay" do
                expect(policy.delay_for(1)).to eq(0.5)
                expect(policy.delay_for(2)).to eq(1.0)
                expect(policy.delay_for(3)).to eq(2.0)
            end

            it "does not exceed the maximum delay" do
                slow = described_class.new(base_delay: 2.0, max_delay: 3.0)

                expect(slow.delay_for(1)).to eq(2.0)
                expect(slow.delay_for(3)).to eq(3.0)
            end
        end
    end

    describe ".call" do
        it "returns the result of the block when it succeeds" do
            attempts = 0
            result = described_class.call(**options) do
                attempts += 1
                "uploaded"
            end

            expect(result).to eq("uploaded")
            expect(attempts).to eq(1)
            expect(sleeps).to be_empty
        end

        it "retries transient failures until the operation succeeds" do
            attempts = 0
            result = described_class.call(**options) do
                attempts += 1
                raise transient_error, "connection reset" if attempts < 3

                "uploaded"
            end

            expect(result).to eq("uploaded")
            expect(attempts).to eq(3)
            expect(sleeps).to eq([0.5, 1.0])
        end

        it "writes the retries to the diagnostics" do
            attempts = 0
            described_class.call(**options) do
                attempts += 1
                raise transient_error, "connection reset" if attempts == 1

                "uploaded"
            end

            expect(log_output.string).to include("Retrying upload of photo.jpg in 0.5s")
            expect(log_output.string).to include("connection reset")
        end

        it "raises the last error when the attempts are exhausted" do
            attempts = 0

            expect do
                described_class.call(**options) do
                    attempts += 1
                    raise transient_error, "connection reset"
                end
            end.to raise_error(transient_error, "connection reset")

            expect(attempts).to eq(3)
            expect(sleeps).to eq([0.5, 1.0])
        end

        it "does not retry failures that are not transient" do
            attempts = 0

            expect do
                described_class.call(**options) do
                    attempts += 1
                    raise ArgumentError, "invalid bucket"
                end
            end.to raise_error(ArgumentError, "invalid bucket")

            expect(attempts).to eq(1)
            expect(sleeps).to be_empty
        end

        it "waits with the default strategy when no sleeper is given" do
            expect do
                described_class.call(
                    policy: R2::Retry::Policy.new(max_attempts: 2, base_delay: 0),
                    retry_on: [transient_error],
                    description: "list"
                ) { raise transient_error, "connection reset" }
            end.to raise_error(transient_error, "connection reset")
        end
    end

    describe ".transient?" do
        it "recognizes the informed error classes" do
            expect(described_class.transient?(ArgumentError.new, [StandardError])).to be(true)
            expect(described_class.transient?(StandardError.new, [ArgumentError])).to be(false)
        end

        it "does not consider any error transient without a configuration" do
            expect(described_class.transient?(StandardError.new, [])).to be(false)
        end
    end
end
