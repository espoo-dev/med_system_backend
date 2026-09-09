# frozen_string_literal: true

module MedicalShiftRecurrences
  class GeneratePending < Actor
    input :target_date, type: Date, default: -> { 2.months.from_now.to_date }

    output :processed, type: Integer, default: 0
    output :shifts_created, type: Integer, default: 0
    output :shifts_created_ids, type: Array, default: -> { [] }
    output :errors, type: Array, default: -> { [] }

    def call
      Rails.logger.info("MedicalShiftRecurrences::GeneratePending starting target_date=#{target_date}")
      initialize_outputs

      MedicalShiftRecurrence.needs_generation(target_date:).find_each do |recurrence|
        process_recurrence(recurrence)
      end

      log_summary
    end

    private

    def initialize_outputs
      self.processed = 0
      self.shifts_created = 0
      self.shifts_created_ids = []
      self.errors = []
    end

    def process_recurrence(recurrence)
      created_ids = generate_shifts_for(recurrence)
      recurrence.update!(last_generated_until: target_date) if created_ids.any?

      self.processed += 1
      self.shifts_created += created_ids.count
      shifts_created_ids.concat(created_ids)

      log_recurrence_processed(recurrence, created_ids)
    rescue StandardError => e
      log_recurrence_failed(recurrence, e)
      errors << { recurrence_id: recurrence.id, error: e.message }
    end

    def generate_shifts_for(recurrence)
      dates = MedicalShiftRecurrences::RecurrenceDateCalculatorService.new(recurrence).dates_until(target_date)

      dates.filter_map do |date|
        result = MedicalShifts::Create.call(
          attributes: shift_attributes(recurrence, date),
          user_id: recurrence.user_id
        )
        result.medical_shift.id if result.success?
      end
    end

    def log_recurrence_processed(recurrence, created_ids)
      Rails.logger.info(
        "MedicalShiftRecurrences::GeneratePending processed recurrence " \
        "recurrence_id=#{recurrence.id} user_id=#{recurrence.user_id} " \
        "shifts_created_count=#{created_ids.count} shifts_created_ids=#{created_ids}"
      )
    end

    def log_recurrence_failed(recurrence, error)
      Rails.logger.error(
        "MedicalShiftRecurrences::GeneratePending failed recurrence " \
        "recurrence_id=#{recurrence.id} user_id=#{recurrence.user_id} error=#{error.message}"
      )
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
        "MedicalShiftRecurrences::GeneratePending finished " \
        "processed_count=#{processed} shifts_created_count=#{shifts_created} " \
        "shifts_created_ids=#{shifts_created_ids} errors_count=#{errors.count}"
      )
    end
  end
end
