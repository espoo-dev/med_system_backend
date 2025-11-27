# frozen_string_literal: true

namespace :medical_shift_recurrences do # rubocop:disable Metrics/BlockLength
  desc "Generate pending medical shift recurrences"
  task generate_pending: :environment do # rubocop:disable Metrics/BlockLength
    start_time = Time.current

    Rails.logger.info "[MedicalShiftRecurrences] Starting generation at #{start_time}"
    puts "Starting generation of pending medical shift recurrences..."
    puts "=" * 80

    begin
      recurrences_needing_generation = MedicalShiftRecurrences::NeedsGenerationQuery.call(
        target_date: 2.months.from_now.to_date
      )

      puts "Found #{recurrences_needing_generation.count} recurrences needing generation:"
      puts "-" * 80

      recurrences_needing_generation.each do |recurrence|
        puts "  ID: #{recurrence.id} | User: #{recurrence.user_id} | " \
             "Frequency: #{recurrence.frequency} | " \
             "Hospital: #{recurrence.hospital_name}"
      end
      puts "-" * 80
      puts ""

      result = MedicalShiftRecurrences::GeneratePending.result

      Rails.logger.info "[MedicalShiftRecurrences] Processed: #{result.processed} recurrences"
      Rails.logger.info "[MedicalShiftRecurrences] Shifts created: #{result.shifts_created}"

      puts "RESULTS:"
      puts "  Processed: #{result.processed} recurrences"
      puts "  Shifts created: #{result.shifts_created}"
      puts ""

      if result.errors.any?
        Rails.logger.error "[MedicalShiftRecurrences] #{result.errors.count} errors encountered"
        puts "ERRORS ENCOUNTERED (#{result.errors.count}):"
        puts "=" * 80

        result.errors.each do |error|
          recurrence = MedicalShiftRecurrence.with_deleted.find_by(id: error[:recurrence_id])

          error_msg = "Recurrence ID: #{error[:recurrence_id]}"

          if recurrence
            error_msg += "\n  User ID: #{recurrence.user_id}"
            error_msg += "\n  Frequency: #{recurrence.frequency}"
            error_msg += "\n  Day of week: #{recurrence.day_of_week}" if recurrence.day_of_week
            error_msg += "\n  Day of month: #{recurrence.day_of_month}" if recurrence.day_of_month
            error_msg += "\n  Hospital: #{recurrence.hospital_name}"
            error_msg += "\n  Start date: #{recurrence.start_date}"
            error_msg += "\n  Last generated until: #{recurrence.last_generated_until}"
          else
            error_msg += "\n  (Recurrence not found in database)"
          end

          error_msg += "\n Error: #{error[:error]}"

          Rails.logger.error "[MedicalShiftRecurrences] #{error_msg}"
          puts error_msg
          puts "-" * 80
        end
      else
        Rails.logger.info "[MedicalShiftRecurrences] No errors encountered"
        puts "No errors encountered"
      end

      duration = Time.current - start_time
      Rails.logger.info "[MedicalShiftRecurrences] Completed in #{duration.round(2)} seconds"

      puts ""
      puts "=" * 80
      puts "Generation completed successfully in #{duration.round(2)} seconds!"

      if result.shifts_created.positive?
        puts ""
        puts "Sample of created shifts (last 5):"
        puts "-" * 80

        recent_shifts = MedicalShift.order(created_at: :desc).limit(5)
        recent_shifts.each do |shift|
          puts "  ID: #{shift.id} | Date: #{shift.start_date} | " \
               "Hospital: #{shift.hospital_name} | " \
               "Recurrence ID: #{shift.medical_shift_recurrence_id}"
        end
      end
    rescue StandardError => e
      Rails.logger.error "[MedicalShiftRecurrences] Fatal error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      puts ""
      puts "=" * 80
      puts "FATAL ERROR:"
      puts "  #{e.message}"
      puts ""
      puts "Backtrace:"
      puts e.backtrace.first(10).join("\n")
      puts "=" * 80

      raise
    end
  end
end
