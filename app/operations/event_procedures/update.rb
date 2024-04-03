# frozen_string_literal: true

module EventProcedures
  class Update < Actor
    input :id, type: String
    input :attributes, type: Hash

    output :event_procedure, type: EventProcedure

    def call
      self.event_procedure = find_event_procedure

      ActiveRecord::Base.transaction do
        handled_attributes
        handle_update_procedure(event_procedure)
      end
    end

    private

    def find_event_procedure
      EventProcedures::Find.result(id: id).event_procedure
    end

    def find_or_create_patient(patient_attributes)
      Patients::FindOrCreate.result(params: patient_attributes).patient
    end

    def find_or_create_procedure(procedure_attributes)
      Procedures::FindOrCreate.result(params: procedure_attributes).procedure
    end

    def find_or_create_health_insurance(health_insurance_attributes)
      HealthInsurances::FindOrCreate.result(params: health_insurance_attributes).health_insurance
    end

    def handle_update_procedure(event_procedure)
      event_procedure.assign_attributes(handled_attributes)
      total_amount_cents = recalculated_total_amount(event_procedure)
      attributes = handled_attributes.reverse_merge(total_amount_cents: total_amount_cents)

      fail!(error: event_procedure.errors.full_messages) unless event_procedure.update(attributes)
    end

    def handled_attributes
      handle_patient_attributes
      handle_procedure_attributes
      handle_health_insurance_attributes

      attributes
    end

    def handle_patient_attributes
      patient_attributes = attributes.delete(:patient_attributes)
      return unless patient_attributes

      patient = find_or_create_patient(patient_attributes)
      attributes[:patient_id] = patient.id
    end

    def handle_procedure_attributes
      procedure_attributes = attributes.delete(:procedure_attributes)
      return unless procedure_attributes

      procedure = find_or_create_procedure(procedure_attributes)
      fail!(error: procedure.errors.full_messages) if procedure.errors.any?
      attributes[:procedure_id] = procedure.id
    end

    def handle_health_insurance_attributes
      health_insurance_attributes = attributes.delete(:health_insurance_attributes)
      return unless health_insurance_attributes

      health_insurance = find_or_create_health_insurance(health_insurance_attributes)
      fail!(error: health_insurance.errors.full_messages) if health_insurance.errors.any?
      attributes[:health_insurance_id] = health_insurance.id
    end

    def recalculated_total_amount(event_procedure)
      EventProcedures::BuildTotalAmountCents.result(event_procedure: event_procedure).total_amount_cents
    end
  end
end
