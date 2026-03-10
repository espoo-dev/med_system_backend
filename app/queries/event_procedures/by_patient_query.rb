# frozen_string_literal: true

module EventProcedures
  class ByPatientQuery < ApplicationQuery
    attr_reader :patient_name, :relation

    def initialize(patient_name:, relation: EventProcedure)
      @patient_name = patient_name
      @relation = relation
    end

    def call
      relation.joins(:patient).where("patients.name ILIKE ?", "%#{patient_name}%")
    end
  end
end
