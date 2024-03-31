# frozen_string_literal: true

require "rails_helper"

RSpec.describe HealthInsurances::List, type: :operation do
  describe ".result" do
    it "is successful" do
      result = described_class.result

      expect(result).to be_success
    end

    it "returns all health insurances ordered by created_at desc" do
      today_health_insurance = create(:health_insurance, created_at: Time.zone.today)
      tomorrow_health_insurance = create(:health_insurance, created_at: Time.zone.tomorrow)
      yesterday_health_insurance = create(:health_insurance, created_at: Time.zone.yesterday)

      result = described_class.result

      expect(result.health_insurances).to eq(
        [
          tomorrow_health_insurance,
          today_health_insurance,
          yesterday_health_insurance
        ]
      )
    end

    context "when custom is true" do
      it "returns only the custom health_insurances for the given user" do
        user = create(:user)
        another_user = create(:user)
        custom_health_insurance = create(:health_insurance, custom: true, user: user)
        _another_custom_health_insurance = create(:health_insurance, custom: true, user: another_user)
        _non_custom_health_insurance = create(:health_insurance, custom: false)

        result = described_class.result(params: { custom: "true" }, user: user)

        expect(result.health_insurances).to contain_exactly(custom_health_insurance)
      end
    end

    context "when custom is false" do
      it "returns only the non-custom health_insurances" do
        user = create(:user)
        _custom_health_insurance = create(:health_insurance, custom: true, user: user)
        non_custom_health_insurance = create(:health_insurance, custom: false)

        result = described_class.result(params: { custom: "false" }, user: user)

        expect(result.health_insurances).to contain_exactly(non_custom_health_insurance)
      end
    end
  end

  context "when has pagination via page and per_page" do
    it "paginate the health insurances" do
      create_list(:health_insurance, 8)

      result = described_class.result(params: { page: 1, per_page: 5 })

      expect(result.health_insurances.count).to eq 5
    end
  end
end
