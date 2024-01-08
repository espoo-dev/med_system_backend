# frozen_string_literal: true

require "rails_helper"

RSpec.describe HealthInsurances::Create, type: :operation do
  describe ".result" do
    context "when attributes are valid" do
      let(:valid_attributes) { attributes_for(:health_insurance) }

      it "returns successfull" do
        result = described_class.result(attributes: valid_attributes)

        expect(result).to be_success
      end

      it "creates a health_insurance" do
        expect do
          described_class.result(attributes: valid_attributes)
        end.to change(HealthInsurance, :count).by(1)
      end
    end

    context "when attributes are invalid" do
      let(:invalid_attributes) { attributes_for(:health_insurance, name: nil) }

      it "is failure" do
        result = described_class.result(attributes: invalid_attributes)

        expect(result).to be_failure
      end

      it "does not create a health_insurance" do
        result = described_class.result(attributes: invalid_attributes)

        expect(result.health_insurance).not_to be_persisted
      end
    end
  end
end
