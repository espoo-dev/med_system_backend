# frozen_string_literal: true

require "rails_helper"

RSpec.describe Procedures::List, type: :operation do
  describe ".result" do
    it "is successful" do
      result = described_class.result

      expect(result).to be_success
    end

    it "returns all procedures ordered by created_at desc" do
      today_procedure = create(:procedure, created_at: Time.zone.today)
      tomorrow_procedure = create(:procedure, created_at: Time.zone.tomorrow)
      yesterday_procedure = create(:procedure, created_at: Time.zone.yesterday)

      result = described_class.result

      expect(result.procedures).to eq(
        [
          tomorrow_procedure,
          today_procedure,
          yesterday_procedure
        ]
      )
    end
  end

  context "when has pagination via page and per_page" do
    it "paginate the procedures" do
      create_list(:procedure, 8)

      result = described_class.result(params: { page: 1, per_page: 5 })

      expect(result.procedures.count).to eq 5
    end
  end
end
