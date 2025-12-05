# frozen_string_literal: true

module MedicalShiftRecurrences
  class Create < Actor
    input :attributes, type: Hash
    input :user_id, type: Integer

    output :medical_shift_recurrence, type: MedicalShiftRecurrence
    output :shifts_created, type: Array, default: -> { [] }

    GENERATION_HORIZON_MONTHS = 2

    def call
      create_recurrence
      initialize_shifts_array
      generate_shifts
      log_success
    end

    private

    def create_recurrence
      self.medical_shift_recurrence = MedicalShiftRecurrence.new(
        attributes.reverse_merge(user_id: user_id)
      )

      return if medical_shift_recurrence.save

      log_error(medical_shift_recurrence.errors.full_messages)
      fail!(error: medical_shift_recurrence.errors.full_messages)
    end

    def initialize_shifts_array
      self.shifts_created = []
    end

    def generate_shifts
      target_date = GENERATION_HORIZON_MONTHS.months.from_now.to_date
      dates = MedicalShiftRecurrences::RecurrenceDateCalculatorService.new(
        medical_shift_recurrence
      ).dates_until(target_date)

      dates.each do |date|
        result = MedicalShifts::Create.result(
          attributes: shift_attributes(date),
          user_id: user_id
        )

        shifts_created << result.medical_shift if result.success?
      end

      medical_shift_recurrence.update!(last_generated_until: target_date) if shifts_created.any?
    end

    def shift_attributes(date)
      {
        start_date: date,
        start_hour: medical_shift_recurrence.start_hour,
        workload: medical_shift_recurrence.workload,
        hospital_name: medical_shift_recurrence.hospital_name,
        amount_cents: medical_shift_recurrence.amount_cents,
        medical_shift_recurrence_id: medical_shift_recurrence.id,
        paid: false
      }
    end

    def log_success
      Rails.logger.info(
        ">>> MedicalShiftRecurrence created successfully. ID: #{medical_shift_recurrence.id}, " \
        "User ID: #{user_id}, Shifts Created: #{shifts_created.count}"
      )
    end

    def log_error(errors)
      Rails.logger.error(
        ">>> Failed to create MedicalShiftRecurrence. User ID: #{user_id}, Errors: #{errors.join(', ')}"
      )
    end
  end
end
