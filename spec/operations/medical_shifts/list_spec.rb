# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::List, type: :operation do
  describe ".result" do
    context "with valid params" do
      it "is successful" do
        create_list(:medical_shift, 3)

        result = described_class.result(page: nil, per_page: nil)

        expect(result.success?).to be true
      end

      it "returns medical_shifts ordered by created_at desc" do
        today_medical_shift = create(:medical_shift, created_at: Time.zone.today)
        yesterday_medical_shift = create(:medical_shift, created_at: Time.zone.yesterday)
        tomorrow_medical_shift = create(:medical_shift, created_at: Time.zone.tomorrow)

        result = described_class.result(page: nil, per_page: nil)

        expect(result.medical_shifts).to eq [tomorrow_medical_shift, today_medical_shift, yesterday_medical_shift]
      end

      it "includes hospital" do
        create(:medical_shift)
        result = described_class.result(page: nil, per_page: nil)

        expect(result.medical_shifts.first.association(:hospital).loaded?).to be true
      end

      context "when has pagination via page and per_page" do
        it "returns the medical_shifts paginated" do
          create_list(:medical_shift, 5)

          result = described_class.result(page: "1", per_page: "3")

          expect(result.medical_shifts.count).to eq 3
        end
      end
    end
  end
end
