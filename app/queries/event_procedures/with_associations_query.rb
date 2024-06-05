# frozen_string_literal: true

module EventProcedures
  class WithAssociationsQuery < ApplicationQuery
    attr_reader :relation

    def initialize(relation: EventProcedure)
      @relation = relation
    end

    def call
      relation
        .joins(:procedure, :patient, :hospital, :health_insurance)
        .select(
          "event_procedures.*",
          "procedures.name as procedure_name",
          "procedures.amount_cents as procedure_amount_cents",
          "procedures.description as procedure_description",
          "patients.name as patient_name",
          "hospitals.name as hospital_name",
          "health_insurances.name as health_insurance_name"
        )
    end
  end
end
