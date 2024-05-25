# frozen_string_literal: true

require "csv"

module Scripts
  class PopulateProcedures
    attr_reader :file_name

    def initialize(file_name)
      @file_name = file_name
    end

    def run!
      populate_database!
    end

    private

    def populate_database!
      ActiveRecord::Base.transaction do
        procedures.each do |procedure|
          next if procedure_persisted.include?(procedure[:code])

          procedure_instance = procedure_build(procedure[:code], procedure[:name])

          save_procedure!(procedure_instance)
        end; nil
      rescue StandardError => e
        raise StandardError, e.message
      end
    end

    def save_procedure!(procedure_instance)
      success_message = success_message(procedure_instance.code)

      Rails.logger.debug(message)

      puts_message(success_message) if procedure_instance.save!
    rescue StandardError => e
      fail_message = fail_message(procedure_instance.code, e)

      logger.warn(fail_message)
      raise StandardError, e.message
    end

    def procedure_build(code, name)
      Procedure.new(code: code, name: name, amount_cents: 1)
    end

    def procedures
      data_file.dig("batch", "procedures")
    end

    def data_file
      @data_file ||= JSON.load_file(path_file).with_indifferent_access
    end

    def path_file
      Rails.root.join("lib/data/procedures/#{file_name}")
    end

    def logger
      @logger ||= Logger.new(Rails.root.join("log/populate_procedures_from_#{file_name}.log"))
    end

    def success_message(code)
      "SUCCESS - Code: #{code}"
    end

    def fail_message(code, error)
      "FAIL - Code: #{code} - Error: #{Error.message} - #{error.backtrace[0..6]}"
    end

    def procedure_persisted
      @procedure_persisted ||= Procedure.all.pluck(:code)
    end

    def puts_message(message)
      Rails.logger.debug(message)
    end
  end
end
