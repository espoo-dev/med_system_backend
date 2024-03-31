# frozen_string_literal: true

require "rails_helper"

RSpec.describe HealthInsurances::FindOrCreate, type: :operation do
  describe ".result" do
    let(:user_id) { create(:user).id }

    context "when health_insurance with given id exists" do
      it "is successful" do
        health_insurance = create(:health_insurance)
        params = { id: health_insurance.id }

        result = described_class.result(params: params)

        expect(result).to be_success
      end

      it "returns found health_insurance" do
        health_insurance = create(:health_insurance)
        params = { id: health_insurance.id }

        result = described_class.result(params: params).health_insurance

        expect(result).to eq(health_insurance)
      end
    end

    context "when health_insurance with given id does not exist" do
      it "is successful" do
        params = { id: nil, name: "health_insurance name", custom: true, user_id: }

        result = described_class.result(params: params)

        expect(result).to be_success
      end

      it "creates a health_insurance" do
        params = { id: nil, name: "health_insurance name", custom: true, user_id: }

        result = described_class.result(params: params)

        expect(result.health_insurance).to be_persisted
        expect(result.health_insurance.name).to eq("health_insurance name")
        expect(result.health_insurance.user_id).to eq(user_id)
      end
    end

    context "when params are empty" do
      it "is failure" do
        params = { id: nil, name: "", custom: true }

        result = described_class.result(params: params)

        expect(result).to be_failure
      end

      it "returns errors" do
        params = { id: nil, name: nil, custom: true }

        result = described_class.result(params: params)

        expect(result.error).to eq(:invalid_record)
        expect(result.health_insurance.errors.full_messages).to eq(
          [
            "Name can't be blank",
            "User can't be blank"
          ]
        )
      end
    end
  end
end
