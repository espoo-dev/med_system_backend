# frozen_string_literal: true

require "rails_helper"

RSpec.describe HealthInsurance do
  describe "soft delete behavior" do
    let(:user) { create(:user) }
    let(:health_insurance) { create(:health_insurance, user: user) }

    it_behaves_like "acts as paranoid", :health_insurance
  end

  describe "associations" do
    it { is_expected.to belong_to(:user).optional(true) }

    it { is_expected.to have_many(:event_procedures).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    context "when custom is true" do
      it "validates presence of user_id" do
        health_insurance = described_class.new(name: "HelthInsurance name", custom: true, user_id: nil)

        expect(health_insurance).not_to be_valid
        expect(health_insurance.errors[:user_id]).to include("can't be blank")
      end
    end

    context "when custom is false" do
      it "does not validate presence of user_id" do
        health_insurance = described_class.new(name: "HelthInsurance name", custom: false, user_id: nil)

        expect(health_insurance).to be_valid
      end
    end

    context "when validates uniqueness of name by user" do
      it "does not allow duplicate name for the same user" do
        user = create(:user)
        create(:health_insurance, name: "Sulamerica", user: user)
        new_health_insurance = build(:health_insurance, name: "Sulamerica", user: user)

        expect(new_health_insurance).not_to be_valid
        expect(new_health_insurance.errors[:name]).to include("has already been taken")
      end

      it "allows duplicate name for different users" do
        user = create(:user)
        create(:health_insurance, name: "Sulamerica", user: user)
        new_health_insurance = build(:health_insurance, name: "Sulamerica")

        expect(new_health_insurance).to be_valid
        expect(new_health_insurance.errors).to be_empty
      end
    end
  end
end
