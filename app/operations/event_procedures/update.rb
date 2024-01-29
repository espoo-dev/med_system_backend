# frozen_string_literal: true

module EventProcedures
  class Update < Actor
    input :id, type: String
    input :attributes, type: Hash

    output :event_procedure, type: EventProcedure

    def call
      self.event_procedure = find_event_procedure

      ActiveRecord::Base.transaction do
        event_procedure.assign_attributes(attributes)
        total_amount_cents = recalculated_total_amount(event_procedure)
        event_procedure.update!(attributes.reverse_merge(total_amount_cents: total_amount_cents))
      rescue StandardError
        fail!(error: :invalid_record)
      end
    end

    private

    def find_event_procedure
      EventProcedures::Find.result(id: id).event_procedure
    end

    def recalculated_total_amount(event_procedure)
      EventProcedures::BuildTotalAmountCents.result(event_procedure: event_procedure).total_amount_cents
    end
  end
end
