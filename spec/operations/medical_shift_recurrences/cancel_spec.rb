# frozen_string_literal: true

# spec/operations/medical_shift_recurrences/cancel_spec.rb
require "rails_helper"

RSpec.describe MedicalShiftRecurrences::Cancel, type: :operation do
  describe ".result" do
    let(:user) { create(:user) }
    let(:recurrence) do
      create(
        :medical_shift_recurrence,
        user: user,
        frequency: "weekly",
        day_of_week: 1,
        start_date: Time.zone.tomorrow
      )
    end

    before do
      result = MedicalShiftRecurrences::Create.result(
        attributes: recurrence.attributes.slice(
          "frequency", "day_of_week", "start_date", "workload",
          "start_hour", "hospital_name", "amount_cents"
        ),
        user_id: user.id
      )

      result.shifts_created.each do |shift|
        shift.update!(medical_shift_recurrence: recurrence)
      end
    end

    context "with valid recurrence" do
      it "is successful" do
        result = described_class.result(medical_shift_recurrence: recurrence)

        expect(result.success?).to be true
      end

      it "soft deletes the recurrence" do
        described_class.result(medical_shift_recurrence: recurrence)

        expect(recurrence.reload.deleted?).to be true
      end

      it "sets deleted_at timestamp" do
        described_class.result(medical_shift_recurrence: recurrence)

        expect(recurrence.reload.deleted_at).to be_present
      end

      it "soft deletes future shifts" do
        future_shifts_count = recurrence.medical_shifts
          .where("start_date >= ?", Date.current)
          .count

        expect(future_shifts_count).to be > 0

        described_class.result(medical_shift_recurrence: recurrence)

        active_future_shifts = MedicalShift
          .where(medical_shift_recurrence: recurrence)
          .where("start_date >= ?", Date.current)
          .count

        expect(active_future_shifts).to eq(0)
      end

      it "returns the number of shifts cancelled" do
        future_shifts_count = recurrence.medical_shifts
          .where("start_date >= ?", Date.current)
          .count

        result = described_class.result(medical_shift_recurrence: recurrence)

        expect(result.shifts_cancelled).to eq(future_shifts_count)
      end

      it "does not delete past shifts" do
        # Criar um shift no passado
        past_shift = create(
          :medical_shift,
          user: user,
          medical_shift_recurrence: recurrence,
          start_date: 1.week.ago.to_date
        )

        described_class.result(medical_shift_recurrence: recurrence)

        expect(past_shift.reload.deleted?).to be false
      end

      it "wraps everything in a transaction" do
        # Simular erro no destroy
        allow(recurrence).to receive(:destroy).and_raise(ActiveRecord::RecordInvalid)

        expect do
          described_class.result(medical_shift_recurrence: recurrence)
        end.to raise_error(ActiveRecord::RecordInvalid)

        # Shifts não devem ter sido deletados
        active_shifts = MedicalShift
          .where(medical_shift_recurrence: recurrence)
          .where("start_date >= ?", Date.current)
          .count

        expect(active_shifts).to be > 0
      end
    end

    context "when destroy returns false without raising (e.g. an aborted callback)" do
      it "fails" do
        allow(recurrence).to receive(:destroy).and_return(false)

        result = described_class.result(medical_shift_recurrence: recurrence)

        expect(result.success?).to be false
        expect(result.error).to eq("Failed to destroy recurrence")
      end

      it "does not report shifts as cancelled" do
        allow(recurrence).to receive(:destroy).and_return(false)

        result = described_class.result(medical_shift_recurrence: recurrence)

        expect(result.shifts_cancelled).to eq(0)
        expect(result.cancelled_shift_ids).to eq([])
      end

      it "logs the failure as an error" do
        allow(recurrence).to receive(:destroy).and_return(false)

        expect(Rails.logger).to receive(:error).with(/Failed to destroy recurrence/)

        described_class.result(medical_shift_recurrence: recurrence)
      end
    end

    context "when a future shift fails to destroy" do
      let!(:future_shifts) { recurrence.medical_shifts.where("start_date >= ?", Date.current).to_a }
      let(:failing_shift) { future_shifts.first }

      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(MedicalShift).to receive(:destroy).and_wrap_original do |original, *args|
          original.receiver.id == failing_shift.id ? false : original.call(*args)
        end
        # rubocop:enable RSpec/AnyInstance
      end

      it "fails" do
        result = described_class.result(medical_shift_recurrence: recurrence)

        expect(result.success?).to be false
      end

      it "returns a descriptive error" do
        result = described_class.result(medical_shift_recurrence: recurrence)

        expect(result.error).to eq("Failed to destroy all future shifts")
      end

      it "rolls back the recurrence destroy" do
        described_class.result(medical_shift_recurrence: recurrence)

        expect(recurrence.reload.deleted?).to be false
      end

      it "rolls back the other shifts already destroyed in the same attempt" do
        described_class.result(medical_shift_recurrence: recurrence)

        expect(MedicalShift.where(id: future_shifts.map(&:id)).count).to eq(future_shifts.count)
      end

      it "does not report shifts as cancelled" do
        result = described_class.result(medical_shift_recurrence: recurrence)

        expect(result.shifts_cancelled).to eq(0)
        expect(result.cancelled_shift_ids).to eq([])
      end

      it "logs the failure as an error" do
        expect(Rails.logger).to receive(:error).with(/Failed to destroy all future shifts/)

        described_class.result(medical_shift_recurrence: recurrence)
      end
    end

    context "when recurrence is already deleted" do
      before do
        recurrence.destroy
      end

      it "fails" do
        result = described_class.result(medical_shift_recurrence: recurrence)

        expect(result).to be_failure
      end

      it "returns already cancelled error" do
        result = described_class.result(medical_shift_recurrence: recurrence)

        expect(result.error).to eq("Recurrence already cancelled")
      end

      it "does not try to delete shifts" do
        expect do
          described_class.result(medical_shift_recurrence: recurrence)
        end.not_to change(MedicalShift.with_deleted, :count)
      end

      it "logs the failure as a warning, not an error" do
        expect(Rails.logger).to receive(:warn).with(/Recurrence already cancelled/)
        expect(Rails.logger).not_to receive(:error)

        described_class.result(medical_shift_recurrence: recurrence)
      end
    end

    context "when recurrence has no future shifts" do
      let(:recurrence_without_shifts) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 1,
          start_date: Date.tomorrow
        )
      end

      it "is successful" do
        result = described_class.result(
          medical_shift_recurrence: recurrence_without_shifts
        )

        expect(result.success?).to be true
      end

      it "returns zero shifts cancelled" do
        result = described_class.result(
          medical_shift_recurrence: recurrence_without_shifts
        )

        expect(result.shifts_cancelled).to eq(0)
      end

      it "still soft deletes the recurrence" do
        described_class.result(
          medical_shift_recurrence: recurrence_without_shifts
        )

        expect(recurrence_without_shifts.reload.deleted?).to be true
      end
    end

    context "when some shifts are already deleted" do
      before do
        # Deletar alguns shifts
        recurrence.medical_shifts.first(2).each(&:destroy)
      end

      it "only counts non-deleted future shifts" do
        remaining_future_shifts = recurrence.medical_shifts
          .where("start_date >= ?", Date.current)
          .count

        result = described_class.result(medical_shift_recurrence: recurrence)

        expect(result.shifts_cancelled).to eq(remaining_future_shifts)
      end
    end
  end
end
