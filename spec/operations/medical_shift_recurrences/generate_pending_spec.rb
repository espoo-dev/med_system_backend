# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShiftRecurrences::GeneratePending, type: :operation do
  describe ".result" do
    let(:user) { create(:user) }

    context "with recurrences that need generation" do
      let!(:recurrence_without_generation) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 1,
          start_date: Time.zone.tomorrow,
          last_generated_until: nil
        )
      end

      let!(:recurrence_with_old_generation) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 3,
          start_date: Time.zone.tomorrow,
          last_generated_until: 1.month.from_now.to_date
        )
      end

      let!(:up_to_date_recurrence) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 5,
          start_date: Time.zone.tomorrow,
          last_generated_until: 6.months.from_now.to_date
        )
      end

      let!(:deleted_recurrence) do
        create(
          :medical_shift_recurrence, :deleted,
          user: user,
          frequency: "weekly",
          day_of_week: 2,
          start_date: Time.zone.tomorrow,
          last_generated_until: nil
        )
      end

      it "is successful" do
        result = described_class.result

        expect(result.success?).to be true
      end

      it "processes recurrences that need generation" do
        result = described_class.result

        expect(result.processed).to eq(2)
      end

      it "generates shifts for recurrences without generation" do
        _result = described_class.result

        expect(recurrence_without_generation.reload.medical_shifts.count).to be > 0
      end

      it "generates additional shifts for recurrences with old generation" do
        initial_count = recurrence_with_old_generation.medical_shifts.count

        _result = described_class.result

        expect(recurrence_with_old_generation.reload.medical_shifts.count).to be > initial_count
      end

      it "does not process up-to-date recurrences" do
        _result = described_class.result

        expect(up_to_date_recurrence.reload.last_generated_until)
          .to eq(6.months.from_now.to_date)
      end

      it "does not process deleted recurrences" do
        _result = described_class.result

        expect(deleted_recurrence.reload.medical_shifts.count).to eq(0)
      end

      it "returns the total number of shifts created" do
        result = described_class.result

        expect(result.shifts_created).to be > 0
      end

      it "updates last_generated_until for processed recurrences" do
        target_date = 4.months.from_now.to_date

        _result = described_class.result(target_date: target_date)

        expect(recurrence_without_generation.reload.last_generated_until).to eq(target_date)
        expect(recurrence_with_old_generation.reload.last_generated_until).to eq(target_date)
      end

      it "returns empty errors array when all succeed" do
        result = described_class.result

        expect(result.errors).to be_empty
      end
    end

    context "with custom target_date" do
      let!(:recurrence) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 1,
          start_date: Time.zone.tomorrow,
          last_generated_until: nil
        )
      end

      it "generates shifts until the specified target_date" do
        target_date = 2.months.from_now.to_date

        _result = described_class.result(target_date: target_date)

        expect(recurrence.reload.last_generated_until).to eq(target_date)
      end
    end

    context "when errors occur during generation" do
      let!(:recurrence) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 1,
          start_date: Time.zone.tomorrow,
          last_generated_until: nil
        )
      end

      before do
        allow(MedicalShifts::Create).to receive(:call)
          .and_raise(StandardError.new("Database connection failed"))
      end

      it "is still successful" do
        result = described_class.result

        expect(result.success?).to be true
      end

      it "captures errors" do
        result = described_class.result

        expect(result.errors).not_to be_empty
        expect(result.errors.first[:recurrence_id]).to eq(recurrence.id)
        expect(result.errors.first[:error]).to include("Database connection failed")
      end
    end

    context "with no recurrences needing generation" do
      it "is successful" do
        result = described_class.result

        expect(result.success?).to be true
      end

      it "processes zero recurrences" do
        result = described_class.result

        expect(result.processed).to eq(0)
      end

      it "creates zero shifts" do
        result = described_class.result

        expect(result.shifts_created).to eq(0)
      end

      it "has no errors" do
        result = described_class.result

        expect(result.errors).to be_empty
      end
    end

    context "with recurrence ending before target_date" do
      let!(:recurrence_with_end_date) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 1,
          start_date: Time.zone.tomorrow,
          end_date: 1.month.from_now.to_date,
          last_generated_until: nil
        )
      end

      it "does not generate shifts beyond end_date" do
        _result = described_class.result(target_date: 6.months.from_now.to_date)

        recurrence_with_end_date.reload.medical_shifts.each do |shift|
          expect(shift.start_date).to be <= recurrence_with_end_date.end_date
        end
      end
    end
  end
end
