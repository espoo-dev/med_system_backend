# frozen_string_literal: true

require "csv"

module Scripts
  class CreateCbhpmProcedures
    attr_reader :cbhpm_id, :procedure_id, :port, :anesthetic_port

    def initialize(cbhpm_id, procedure_id, port, anesthetic_port)
      @cbhpm_id = cbhpm_id
      @procedure_id = procedure_id
      @port = port
      @anesthetic_port = anesthetic_port
    end

    def run!
      return attribute_missing_error unless attributes_present?

      create_cbhpm_procedures!
    end

    private

    def create_cbhpm_procedures!
      CbhpmProcedure.create!(
        cbhpm_id: cbhpm_id, procedure_id: procedure_id, port: port,
        anesthetic_port: anesthetic_port.to_i
      )
    end

    def attributes_present?
      return false if cbhpm_id.blank?
      return false if procedure_id.blank?
      return false if port.blank?
      return false if anesthetic_port.blank?

      true
    end

    def attribute_missing_error
      raise StandardError, "Check if all attributes are presents!"
    end
  end
end
