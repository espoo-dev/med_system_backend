# frozen_string_literal: true

require "rails_helper"

RSpec.describe Patients::List, type: :operation do
  describe ".result" do
    it "is successful" do
      result = described_class.result(scope: Patient.all)

      expect(result).to be_success
    end

    it "returns all patients ordered by created_at desc" do
      today_patient = create(:patient, created_at: Time.zone.today)
      tomorrow_patient = create(:patient, created_at: Time.zone.tomorrow)
      yesterday_patient = create(:patient, created_at: Time.zone.yesterday)

      result = described_class.result(scope: Patient.all)

      expect(result.patients).to eq(
        [
          tomorrow_patient,
          today_patient,
          yesterday_patient
        ]
      )
    end
  end

  context "when has pagination via page and per_page" do
    it "paginate the patients" do
      create_list(:patient, 8)

      result = described_class.result(scope: Patient.all, params: { page: 1, per_page: 5 })

      expect(result.patients.count).to eq 5
    end
  end
end
