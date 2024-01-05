# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hospitals::Update, type: :operation do
  describe ".result" do
    context "when attributes are valid" do
      let!(:hospital) { create(:hospital, name: "Old name") }

      it "is successful" do
        attributes = { name: "New name" }

        result = described_class.result(id: hospital.id.to_s, attributes: attributes)

        expect(result).to be_success
      end

      it "updates hospital" do
        attributes = { name: "New name" }

        result = described_class.result(id: hospital.id.to_s, attributes: attributes)

        expect(result.hospital.reload.name).to eq("New name")
      end
    end

    context "when attributes are invalid" do
      let!(:hospital) { create(:hospital, name: "Old name") }

      it "is failure" do
        attributes = { name: nil }

        result = described_class.result(id: hospital.id.to_s, attributes: attributes)

        expect(result).to be_failure
      end

      it "does not update hospital" do
        attributes = { name: nil }

        result = described_class.result(id: hospital.id.to_s, attributes: attributes)

        expect(result.hospital.reload.name).to eq("Old name")
      end

      it "returns error" do
        attributes = { name: nil }

        result = described_class.result(id: hospital.id.to_s, attributes: attributes)

        expect(result.error).to eq(:invalid_record)
      end
    end
  end
end
