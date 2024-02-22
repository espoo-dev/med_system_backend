# frozen_string_literal: true

module EventProcedures
  class Create < Actor
    input :attributes, type: Hash
    input :user_id, type: Integer

    output :event_procedure, type: EventProcedure

    def call
      ActiveRecord::Base.transaction do
        patient = find_or_create_patient
        event_procedure = create_event_procedure(patient)
        assign_total_amount_cents(event_procedure)
      end
    end

    private

    def assign_total_amount_cents(event_procedure)
      build_total_amount = EventProcedures::BuildTotalAmountCents.result(event_procedure: event_procedure)
      event_procedure.total_amount_cents = build_total_amount.total_amount_cents
      event_procedure.save
    end

    def find_or_create_patient
      Patients::FindOrCreate.result(params: attributes[:patient_attributes]).patient
    end

    def create_event_procedure(patient)
      self.event_procedure = EventProcedure.new(attributes.reverse_merge(user_id: user_id, patient: patient))

      fail!(error: event_procedure.errors) unless event_procedure.save

      event_procedure
    end
  end
end
