# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hospitals::List, type: :operation do
  describe ".result" do
    it "is successful" do
      result = described_class.result

      expect(result).to be_success
    end

    it "returns all hospitals ordered by created_at desc" do
      today_hospital = create(:hospital, created_at: Time.zone.today)
      tomorrow_hospital = create(:hospital, created_at: Time.zone.tomorrow)
      yesterday_hospital = create(:hospital, created_at: Time.zone.yesterday)

      result = described_class.result

      expect(result.hospitals).to eq(
        [
          tomorrow_hospital,
          today_hospital,
          yesterday_hospital
        ]
      )
    end
  end

  context "when has pagination via page and per_page" do
    it "paginate the hospitals" do
      create_list(:hospital, 8)

      result = described_class.result(params: { page: 1, per_page: 5 })

      expect(result.hospitals.count).to eq 5
    end
  end
end
