# frozen_string_literal: true

require "csv"
require_relative "create_cbhpm_procedures"

module Scripts
  class PopulateProcedures
    attr_reader :path_file

    def initialize(path_file)
      @path_file = path_file
    end

    def run!
      populate_database!
    end

    private

    def populate_database!
      ActiveRecord::Base.transaction do
        procedures.each do |procedure|
          next if procedure_persisted?(procedure)

          procedure_instance = procedure_build(procedure[:code], procedure[:name])

          save_procedure!(procedure_instance, procedure[:port], procedure[:anesthetic_port])
        end; nil
      rescue StandardError => e
        raise StandardError, e.message
      end
    end

    def save_procedure!(procedure_instance, port, anesthetic_port)
      success_message = success_message(procedure_instance.code)

      puts_message(success_message)

      create_cbhpm_procedures(procedure_instance, port, anesthetic_port) if procedure_instance.save!
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

    def logger
      @logger ||= Logger.new(Rails.root.join("log/populate_procedures_from_batch.log"))
    end

    def success_message(code)
      "SUCCESS - Code: #{code}"
    end

    def fail_message(code, error)
      "FAIL - Code: #{code} - Error: #{error.message} - #{error.backtrace[0..6]}"
    end

    def procedures_persisted
      @procedures_persisted ||= Procedure.all.pluck(:code)
    end

    def puts_message(message)
      Rails.logger.debug(message)
    end

    def procedure_persisted?(procedure)
      return false if procedure.blank?

      if procedures_persisted.include?(procedure[:code])
        logger.info("Code already exists in the database! Code: #{procedure[:code]}")

        return true
      end

      false
    end

    def create_cbhpm_procedures(procedure, port, anesthetic_port)
      return cbhpm_not_existed_error if cbhpm.nil?

      begin
        instance = Scripts::CreateCbhpmProcedures.new(cbhpm.id, procedure.id, port, anesthetic_port)
        instance.run!
      rescue StandardError => e
        raise StandardError, e
      end
    end

    def cbhpm
      @cbhpm ||= Cbhpm.find_by(year: 2008, name: "5 edition")
    end

    def cbhpm_not_existed_error
      raise StandardError, "Cbhpm 5 edition(2008) not created"
    end
  end
end
