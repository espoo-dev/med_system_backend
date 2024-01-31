# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::List, type: :operation do
  describe ".result" do
    context "with valid params" do
      it "is successful" do
        create_list(:medical_shift, 3)

        result = described_class.result(page: nil, per_page: nil, payd: nil, month: nil, hospital_id: nil)

        expect(result.success?).to be true
      end

      it "returns medical_shifts ordered by created_at desc" do
        today_medical_shift = create(:medical_shift, created_at: Time.zone.today)
        yesterday_medical_shift = create(:medical_shift, created_at: Time.zone.yesterday)
        tomorrow_medical_shift = create(:medical_shift, created_at: Time.zone.tomorrow)

        result = described_class.result(page: nil, per_page: nil, payd: nil, month: nil, hospital_id: nil)

        expect(result.medical_shifts).to eq [tomorrow_medical_shift, today_medical_shift, yesterday_medical_shift]
      end

      it "includes hospital" do
        create(:medical_shift)
        result = described_class.result(page: nil, per_page: nil, payd: nil, month: nil, hospital_id: nil)

        expect(result.medical_shifts.first.association(:hospital).loaded?).to be true
      end

      context "when has pagination via page and per_page" do
        it "returns the medical_shifts paginated" do
          create_list(:medical_shift, 5)

          result = described_class.result(page: "1", per_page: "3", payd: nil, month: nil, hospital_id: nil)

          expect(result.medical_shifts.count).to eq 3
        end
      end

      context "when there is the filter per month" do
        it "returns medical_shifts per month" do
          february_medical_shift = create(:medical_shift, date: "2023-02-15")
          _september_medical_shift = create(:medical_shift, date: "2023-09-26")

          result = described_class.result(page: nil, per_page: nil, payd: nil, month: "2", hospital_id: nil)

          expect(result.medical_shifts).to eq [february_medical_shift]
        end
      end

      context "when there is the filter per hospital" do
        it "returns medical_shifts per hospital" do
          hospital = create(:hospital)
          hospital_medical_shift = create(:medical_shift, hospital: hospital)
          _another_hospital_medical_shift = create(:medical_shift)

          result = described_class.result(
            page: nil, per_page: nil, payd: nil, month: nil,
            hospital_id: hospital.id.to_s
          )

          expect(result.medical_shifts).to eq [hospital_medical_shift]
        end
      end

      context "when there is the filter per payd" do
        it "returns paid medical_shifts" do
          paid_medical_shifts = create_list(:medical_shift, 3, was_paid: true)
          _unpaid_medical_shifts = create_list(:medical_shift, 3, was_paid: false)

          result = described_class.result(page: nil, per_page: nil, payd: "true", month: nil, hospital_id: nil)

          expect(result.medical_shifts.to_a).to match_array(paid_medical_shifts)
        end

        it "returns unpaid medical_shifts" do
          _paid_medical_shifts = create_list(:medical_shift, 3, was_paid: true)
          unpaid_medical_shifts = create_list(:medical_shift, 3, was_paid: false)

          result = described_class.result(page: nil, per_page: nil, payd: "false", month: nil, hospital_id: nil)

          expect(result.medical_shifts.to_a).to match_array(unpaid_medical_shifts)
        end
      end
    end
  end
end
