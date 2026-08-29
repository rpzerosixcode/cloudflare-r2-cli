# frozen_string_literal: true

require "spec_helper"
require "r2/version"

RSpec.describe R2 do
    describe "VERSION" do
        it "está definida" do
            expect(R2::VERSION).to be_a(String)
            expect(R2::VERSION).not_to be_empty
        end

        it "segue o padrão de versionamento semântico" do
            expect(R2::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
        end
    end
end
