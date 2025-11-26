# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShiftRecurrences::Create, type: :operation do
  describe ".result" do
    let(:user) { create(:user) }

    context "with valid attributes" do
      context "when creating weekly recurrence" do
        let(:attributes) do
          {
            frequency: "weekly",
            day_of_week: 1,
            start_date: Time.zone.today,
            workload: "six",
            start_hour: "19:00:00",
            hospital_name: "Hospital Teste",
            amount_cents: 120_000
          }
        end

        it "is successful" do
          result = described_class.result(attributes: attributes, user_id: user.id)

          expect(result.success?).to be true
        end

        it "creates a new medical shift recurrence" do
          result = described_class.result(attributes: attributes, user_id: user.id)

          expect(result.medical_shift_recurrence).to be_persisted
          expect(result.medical_shift_recurrence.frequency).to eq("weekly")
          expect(result.medical_shift_recurrence.day_of_week).to eq(1)
        end

        it "generates shifts immediately" do
          result = described_class.result(attributes: attributes, user_id: user.id)

          expect(result.shifts_created).not_to be_empty
          expect(result.shifts_created.count).to be >= 8
        end

        it "generates shifts for 4 months ahead" do
          result = described_class.result(attributes: attributes, user_id: user.id)

          expect(result.medical_shift_recurrence.last_generated_until)
            .to eq(2.months.from_now.to_date)
        end

        it "links shifts to recurrence" do
          result = described_class.result(attributes: attributes, user_id: user.id)

          result.shifts_created.each do |shift|
            expect(shift.medical_shift_recurrence).to eq(result.medical_shift_recurrence)
          end
        end

        it "copies attributes to generated shifts" do # rubocop:disable RSpec/MultipleExpectations
          result = described_class.result(attributes: attributes, user_id: user.id)

          result.shifts_created.each do |shift|
            expect(shift.user_id).to eq(user.id)
            expect(shift.workload).to eq("six")
            expect(shift.hospital_name).to eq("Hospital Teste")
            expect(shift.amount_cents).to eq(120_000)
            expect(shift.paid).to be false
          end
        end
      end

      context "when creating biweekly recurrence" do
        let(:attributes) do
          {
            frequency: "biweekly",
            day_of_week: 5,
            start_date: Date.current,
            workload: "twenty_four",
            start_hour: "07:00",
            hospital_name: "Hospital Central",
            amount_cents: 200_000
          }
        end

        it "is successful" do
          result = described_class.result(attributes: attributes, user_id: user.id)

          expect(result.success?).to be true
        end

        it "generates shifts every two weeks" do
          result = described_class.result(attributes: attributes, user_id: user.id)

          dates = result.shifts_created.map(&:start_date).sort

          dates.each_cons(2) do |date1, date2|
            expect(date2 - date1).to eq(14)
          end
        end

        it "skips the start_date if it matches day_of_week" do
          start_date = Date.current.next_occurring(:friday)
          attributes[:start_date] = start_date

          result = described_class.result(attributes: attributes, user_id: user.id)

          expect(result.shifts_created.first.start_date).to eq(start_date + 14.days)
        end
      end

      context "when creating monthly_fixed_day recurrence" do
        let(:attributes) do
          {
            frequency: "monthly_fixed_day",
            day_of_month: 15,
            start_date: Time.zone.today,
            workload: "twelve",
            start_hour: "19:00",
            hospital_name: "Hospital Regional",
            amount_cents: 150_000
          }
        end

        it "is successful" do
          result = described_class.result(attributes: attributes, user_id: user.id)

          expect(result.success?).to be true
        end

        it "generates shifts on the same day each month" do
          result = described_class.result(attributes: attributes, user_id: user.id)

          result.shifts_created.each do |shift|
            expect(shift.start_date.day).to eq(15)
          end
        end
      end

      context "with end_date" do
        let(:attributes) do
          {
            frequency: "weekly",
            day_of_week: 3,
            start_date: Date.tomorrow,
            end_date: 2.months.from_now.to_date,
            workload: "12h",
            start_hour: "19:00",
            hospital_name: "Hospital Teste",
            amount_cents: 120_000
          }
        end

        it "does not generate shifts after end_date" do
          result = described_class.result(attributes: attributes, user_id: user.id)

          result.shifts_created.each do |shift|
            expect(shift.start_date).to be <= attributes[:end_date]
          end
        end
      end
    end

    context "with invalid attributes" do
      it "fails when frequency is missing" do
        attributes = {
          day_of_week: 1,
          start_date: Date.tomorrow,
          workload: "12h",
          start_hour: "19:00",
          hospital_name: "Hospital Teste",
          amount_cents: 120_000
        }

        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result).to be_failure
      end

      it "does not create a new medical shift recurrence" do
        attributes = { frequency: "weekly", start_date: Date.tomorrow }

        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result.medical_shift_recurrence).not_to be_persisted
        expect(result.medical_shift_recurrence).not_to be_valid
      end

      it "returns an error for weekly without day_of_week" do
        attributes = {
          frequency: "weekly",
          start_date: Date.tomorrow,
          workload: "12h",
          start_hour: "19:00",
          hospital_name: "Hospital Teste",
          amount_cents: 120_000
        }

        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result.error).to be_present
        expect(result.medical_shift_recurrence.errors.full_messages).to eq(
          ["Day of week can't be blank", "Day of week is not a number"]
        )
      end

      it "returns an error for weekly with monthly_fixed_day attribute" do
        attributes = {
          frequency: "weekly",
          day_of_month: 15,
          start_date: Date.tomorrow,
          workload: "12h",
          start_hour: "19:00",
          hospital_name: "Hospital Teste",
          amount_cents: 120_000
        }

        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result.error).to be_present
        expect(result.medical_shift_recurrence.errors.full_messages).to include(
          "Day of month It must be empty for weekly/biweekly recurrence."
        )
      end

      it "returns an error for monthly_fixed_day with with day_of_week attribute" do
        attributes = {
          frequency: "monthly_fixed_day",
          day_of_week: 2,
          start_date: Date.tomorrow,
          workload: "12h",
          start_hour: "19:00",
          hospital_name: "Hospital Teste",
          amount_cents: 120_000
        }

        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result.error).to be_present
        expect(result.medical_shift_recurrence.errors.full_messages).to include(
          "Day of week It must be empty for monthly_fixed_day recurrence."
        )
      end

      it "returns an error for monthly_fixed_day without day_of_month" do
        attributes = {
          frequency: "monthly_fixed_day",
          start_date: Date.tomorrow,
          workload: "12h",
          start_hour: "19:00",
          hospital_name: "Hospital Teste",
          amount_cents: 120_000
        }

        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result.error).to be_present
        expect(result.medical_shift_recurrence.errors.full_messages).to eq(
          ["Day of month can't be blank", "Day of month is not a number"]
        )
      end

      it "returns an error when start_date is in the past" do
        attributes = {
          frequency: "weekly",
          day_of_week: 1,
          start_date: Date.yesterday,
          workload: "12h",
          start_hour: "19:00",
          hospital_name: "Hospital Teste",
          amount_cents: 120_000
        }

        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result.error).to be_present
        expect(result.medical_shift_recurrence.errors.full_messages).to include(
          match(/Start date/)
        )
      end

      it "returns an error when end_date is before start_date" do
        attributes = {
          frequency: "weekly",
          day_of_week: 1,
          start_date: Date.tomorrow,
          end_date: Date.current,
          workload: "12h",
          start_hour: "19:00",
          hospital_name: "Hospital Teste",
          amount_cents: 120_000
        }

        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result.error).to be_present
        expect(result.medical_shift_recurrence.errors.full_messages).to include(
          match(/End date/)
        )
      end

      it "returns validation errors for missing required fields" do
        attributes = { frequency: "weekly", day_of_week: 1 }

        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result.error).to be_present
        expect(result.medical_shift_recurrence.errors.full_messages).to include(
          match(/Start date/),
          match(/Workload/),
          match(/Start hour/),
          match(/Hospital name/)
        )
      end
    end
  end
end
