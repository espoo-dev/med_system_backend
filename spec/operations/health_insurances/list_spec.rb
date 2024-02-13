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
  end

  context "when has pagination via page and per_page" do
    it "paginate the health insurances" do
      create_list(:health_insurance, 8)

      result = described_class.result(params: { page: 1, per_page: 5 })

      expect(result.health_insurances.count).to eq 5
    end
  end
end
