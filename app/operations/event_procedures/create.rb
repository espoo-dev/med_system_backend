# frozen_string_literal: true

module EventProcedures
  class Create < Actor
    input :attributes, type: Hash
    input :user_id, type: Integer

    output :event_procedure, type: EventProcedure

    def call
      self.event_procedure = EventProcedure.new(attributes.reverse_merge(user_id: user_id))

      fail!(error: event_procedure.errors) unless event_procedure.save

      event_procedure.total_amount_cents = total_amount_cents
      event_procedure.save
    end

    private

    def total_amount_cents
      EventProcedures::BuildTotalAmountCents.result(event_procedure: event_procedure).total_amount_cents
    end
  end
end
