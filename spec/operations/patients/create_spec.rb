# frozen_string_literal: true

require "rails_helper"

RSpec.describe Patients::Create, type: :operation do
  describe ".result" do
    let(:user_id) { create(:user).id }

    context "when params are valid" do
      it "is successful" do
        result = described_class.result(attributes: { name: "John", user_id: })

        expect(result).to be_success
      end

      it "creates a patient" do
        result = described_class.result(attributes: { name: "John", user_id: })

        expect(result.patient).to be_persisted
        expect(result.patient.name).to eq("John")
      end
    end

    context "when params are invalid" do
      it "is failure" do
        result = described_class.result(attributes: { name: "", user_id: })

        expect(result).to be_failure
      end

      it "does not create a patient" do
        result = described_class.result(attributes: { name: "", user_id: })

        expect(result.patient).not_to be_persisted
      end
    end
  end
end
