# frozen_string_literal: true

require "spec_helper"
require "r2/content_type"

RSpec.describe R2::ContentType do
    describe ".for" do
        it "maps image extensions" do
            expect(described_class.for("photo.jpg")).to eq("image/jpeg")
            expect(described_class.for("photo.jpeg")).to eq("image/jpeg")
            expect(described_class.for("logo.png")).to eq("image/png")
            expect(described_class.for("animation.gif")).to eq("image/gif")
        end

        it "maps text and document extensions" do
            expect(described_class.for("notes.txt")).to eq("text/plain")
            expect(described_class.for("records.csv")).to eq("text/csv")
            expect(described_class.for("payload.json")).to eq("application/json")
            expect(described_class.for("report.pdf")).to eq("application/pdf")
            expect(described_class.for("archive.zip")).to eq("application/zip")
        end

        it "considers the extension of keys inside directories" do
            expect(described_class.for("uploads/images/photo.gif")).to eq("image/gif")
        end

        it "is case insensitive" do
            expect(described_class.for("PHOTO.JPG")).to eq("image/jpeg")
        end

        it "falls back to the generic binary type for unknown extensions" do
            expect(described_class.for("backup.unknown")).to eq(described_class::DEFAULT)
            expect(described_class.for("README")).to eq(described_class::DEFAULT)
        end
    end

    describe ".extension" do
        it "returns the lowercase extension of the key" do
            expect(described_class.extension("uploads/Photo.JPG")).to eq(".jpg")
        end

        it "returns an empty string when the key has no extension" do
            expect(described_class.extension("uploads/photo")).to eq("")
        end
    end
end
