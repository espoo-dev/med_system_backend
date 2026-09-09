# frozen_string_literal: true

module MedicalShiftRecurrences
  # :reek:MissingSafeMethod { exclude: [ 'fail_and_log!' ] }
  class Cancel < Actor
    input :medical_shift_recurrence, type: MedicalShiftRecurrence

    output :shifts_cancelled, type: Integer, default: 0
    output :cancelled_shift_ids, type: Array, default: -> { [] }

    def call
      fail_and_log!("Recurrence already cancelled", level: :warn) if medical_shift_recurrence.deleted_at.present?

      ActiveRecord::Base.transaction do
        cancel_future_shifts
        fail_and_log!("Failed to destroy recurrence") unless medical_shift_recurrence.destroy
      end

      log_success
    end

    private

    def cancel_future_shifts
      future_shifts = medical_shift_recurrence
        .medical_shifts
        .where(deleted_at: nil)
        .where("start_date >= ?", Date.current)
        .to_a

      self.cancelled_shift_ids = future_shifts.filter_map { |shift| shift.id if shift.destroy }
      self.shifts_cancelled = cancelled_shift_ids.count

      return if shifts_cancelled == future_shifts.count

      fail_and_log!("Failed to destroy all future shifts")
    end

    # Combines logging with fail! (unlike Create/GeneratePending's separate
    # log+fail! calls) so every failure path in this operation - including the
    # batch-shift mismatch found mid-transaction - is guaranteed to log before
    # aborting. Resets the shift-count outputs so a failed Result never reports
    # the pre-rollback partial counts as if they still held.
    def fail_and_log!(reason, level: :error)
      self.shifts_cancelled = 0
      self.cancelled_shift_ids = []
      log_failure(reason, level:)
      fail!(error: reason)
    end

    def log_success
      Rails.logger.info(
        "MedicalShiftRecurrences::Cancel succeeded " \
        "recurrence_id=#{medical_shift_recurrence.id} user_id=#{medical_shift_recurrence.user_id} " \
        "shifts_cancelled_count=#{shifts_cancelled} shifts_cancelled_ids=#{cancelled_shift_ids}"
      )
    end

    def log_failure(reason, level:)
      Rails.logger.public_send(
        level,
        "MedicalShiftRecurrences::Cancel failed " \
        "recurrence_id=#{medical_shift_recurrence.id} user_id=#{medical_shift_recurrence.user_id} reason=#{reason}"
      )
    end
  end
end
