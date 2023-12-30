# frozen_string_literal: true

require "rails_helper"

RSpec.describe Patients::Create, type: :operation do
  describe ".result" do
    context "when params are valid" do
      it "is successful" do
        result = described_class.result(attributes: { name: "John" })

        expect(result).to be_success
      end

      it "creates a patient" do
        result = described_class.result(attributes: { name: "John" })

        expect(result.patient).to be_persisted
        expect(result.patient.name).to eq("John")
      end
    end

    context "when params are invalid" do
      it "is failure" do
        result = described_class.result(attributes: { name: "" })

        expect(result).to be_failure
      end

      it "does not create a patient" do
        result = described_class.result(attributes: { name: "" })

        expect(result.patient).not_to be_persisted
      end
    end
  end
end
