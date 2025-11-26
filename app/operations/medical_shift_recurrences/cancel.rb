# frozen_string_literal: true

module MedicalShiftRecurrences
  class Cancel < Actor
    input :medical_shift_recurrence, type: MedicalShiftRecurrence

    output :shifts_cancelled, type: Integer, default: 0

    def call
      fail!(error: "Recurrence already cancelled") if medical_shift_recurrence.deleted_at.present?

      ActiveRecord::Base.transaction do
        cancel_future_shifts
        medical_shift_recurrence.destroy
      end
    end

    private

    def cancel_future_shifts
      future_shifts = medical_shift_recurrence
        .medical_shifts
        .where(deleted_at: nil)
        .where("start_date >= ?", Date.current)

      self.shifts_cancelled = future_shifts.count
      future_shifts.destroy_all
    end
  end
end
