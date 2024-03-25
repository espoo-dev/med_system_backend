# frozen_string_literal: true

require "rails_helper"

RSpec.describe HealthInsurances::Create, type: :operation do
  describe ".result" do
    context "when attributes are valid" do
      it "returns successfull" do
        valid_attributes = { name: "Sulamerica", custom: false }

        result = described_class.result(attributes: valid_attributes)

        expect(result).to be_success
      end

      it "creates a health_insurance" do
        expect do
          valid_attributes = { name: "Sulamerica", custom: false }

          described_class.result(attributes: valid_attributes)
        end.to change(HealthInsurance, :count).by(1)
      end

      context "when custom attribute is true" do
        it "associates the current user" do
          user = create(:user)
          valid_attributes = { name: "Sulamerica", custom: true }

          result = described_class.result(attributes: valid_attributes, user: user)

          expect(result.health_insurance.user).to eq(user)
        end
      end

      context "when custom attribute is false" do
        it "does not associate the current user" do
          user = create(:user)
          valid_attributes = { name: "Sulamerica", custom: false }

          result = described_class.result(attributes: valid_attributes, user: user)

          expect(result.health_insurance.user).to be_nil
        end
      end
    end

    context "when attributes are invalid" do
      it "is failure" do
        invalid_attributes = { name: nil }

        result = described_class.result(attributes: invalid_attributes)

        expect(result).to be_failure
      end

      it "does not create a health_insurance" do
        invalid_attributes = { name: nil }

        result = described_class.result(attributes: invalid_attributes)

        expect(result.health_insurance).not_to be_persisted
      end
    end
  end
end
