# frozen_string_literal: true

require "rails_helper"

RSpec.describe HealthInsurances::ByCustomQuery do
  context "when custom is true" do
    it "returns only custom health_insurances for the given user" do
      user = create(:user)
      another_user = create(:user)
      custom_health_insurance = create(:health_insurance, custom: true, user: user)
      _another_custom_health_insurance = create(:health_insurance, custom: true, user: another_user)
      _non_custom_health_insurance = create(:health_insurance, custom: false)

      by_custom_query = described_class.call(custom: "true", user: user)

      expect(by_custom_query).to contain_exactly(custom_health_insurance)
    end
  end

  context "when custom is false" do
    it "returns only non-custom health_insurances" do
      user = create(:user)
      _custom_health_insurance = create(:health_insurance, custom: true, user: user)
      health_insurance = create(:health_insurance, custom: false)

      by_custom_query = described_class.call(custom: "false", user: user)

      expect(by_custom_query).to contain_exactly(health_insurance)
    end
  end
end
