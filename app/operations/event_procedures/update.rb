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

    def handle_update_procedure(event_procedure)
      event_procedure.assign_attributes(handled_attributes)
      total_amount_cents = recalculated_total_amount(event_procedure)
      attributes = handled_attributes.reverse_merge(total_amount_cents: total_amount_cents)

      fail!(error: :invalid_record) unless event_procedure.update(attributes)
    end

    def handled_attributes
      patient_attributes = attributes.delete(:patient_attributes)

      if patient_attributes
        patient = find_or_create_patient(patient_attributes)
        attributes[:patient_id] = patient.id
      end

      attributes
    end

    def recalculated_total_amount(event_procedure)
      EventProcedures::BuildTotalAmountCents.result(event_procedure: event_procedure).total_amount_cents
    end
  end
end
