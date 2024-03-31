# frozen_string_literal: true

module EventProcedures
  class Create < Actor
    input :attributes, type: Hash
    input :user_id, type: Integer

    output :event_procedure, type: EventProcedure

    def call
      ActiveRecord::Base.transaction do
        create_event_procedure
        assign_total_amount_cents(event_procedure)
      end
    end

    private

    def assign_total_amount_cents(event_procedure)
      build_total_amount = EventProcedures::BuildTotalAmountCents.result(event_procedure: event_procedure)
      event_procedure.total_amount_cents = build_total_amount.total_amount_cents
      event_procedure.save
    end

    def create_event_procedure
      self.event_procedure = EventProcedure.new(event_procedure_attributes)

      fail!(error: event_procedure.errors) unless event_procedure.save

      event_procedure
    end

    def event_procedure_attributes
      patient = find_or_create_patient
      procedure = find_or_create_procedure
      health_insurance = find_or_create_health_insurance

      validate_procedure(procedure)
      validate_health_insurance(health_insurance)

      merge_attributes(patient, procedure, health_insurance)
    end

    def validate_procedure(procedure)
      fail!(error: procedure.errors) if procedure.errors.any?
    end

    def validate_health_insurance(health_insurance)
      fail!(error: health_insurance.errors) if health_insurance.errors.any?
    end

    def merge_attributes(patient, procedure, health_insurance)
      attributes
        .except(
          :patient_attributes,
          :procedure_attributes,
          :health_insurance_attributes
        ).merge(
          user_id: user_id,
          patient_id: patient.id,
          procedure_id: procedure.id,
          health_insurance_id: health_insurance.id
        )
    end

    def find_or_create_health_insurance
      HealthInsurances::FindOrCreate.result(params: attributes[:health_insurance_attributes]).health_insurance
    end

    def find_or_create_patient
      Patients::FindOrCreate.result(params: attributes[:patient_attributes]).patient
    end

    def find_or_create_procedure
      Procedures::FindOrCreate.result(params: attributes[:procedure_attributes]).procedure
    end
  end
end
