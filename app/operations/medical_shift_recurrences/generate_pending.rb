# frozen_string_literal: true

module MedicalShiftRecurrences
  class GeneratePending < Actor
    input :target_date, type: Date, default: -> { 2.months.from_now.to_date }

    output :processed, type: Integer, default: 0
    output :shifts_created, type: Integer, default: 0
    output :errors, type: Array, default: -> { [] }

    def call
      Rails.logger.info(">>> Starting MedicalShiftRecurrences::GeneratePending for target_date: #{target_date}")
      self.processed = 0
      self.shifts_created = 0
      self.errors = []

      MedicalShiftRecurrence.needs_generation(target_date:).find_each do |recurrence|
        process_recurrence(recurrence)
      end

      log_summary
    end

    private

    def process_recurrence(recurrence)
      dates = MedicalShiftRecurrences::RecurrenceDateCalculatorService.new(recurrence).dates_until(target_date)

      created_count = 0
      dates.each do |date|
        result = MedicalShifts::Create.call(
          attributes: shift_attributes(recurrence, date),
          user_id: recurrence.user_id
        )
        created_count += 1 if result.success?
      end

      recurrence.update!(last_generated_until: target_date) if created_count.positive?

      self.processed += 1
      self.shifts_created += created_count
    rescue StandardError => e
      Rails.logger.error(">>> Error processing recurrence #{recurrence.id}: #{e.message}")
      errors << { recurrence_id: recurrence.id, error: e.message }
    end

    def shift_attributes(recurrence, date)
      {
        start_date: date,
        start_hour: recurrence.start_hour,
        workload: recurrence.workload,
        hospital_name: recurrence.hospital_name,
        amount_cents: recurrence.amount_cents,
        medical_shift_recurrence_id: recurrence.id,
        paid: false
      }
    end

    def log_summary
      Rails.logger.info(
        ">>> Finished MedicalShiftRecurrences::GeneratePending. " \
        "Processed: #{processed}, Shifts Created: #{shifts_created}, Errors: #{errors.count}"
      )
    end
  end
end
