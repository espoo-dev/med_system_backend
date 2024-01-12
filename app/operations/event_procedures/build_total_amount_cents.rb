# frozen_string_literal: true

module EventProcedures
  class BuildTotalAmountCents < Actor
    input :event_procedure, type: EventProcedure

    output :total_amount_cents, type: Integer

    APARTMENT_PERCENTAGE = 1
    URGENCY_PERCENTAGE = 0.3

    def call
      self.total_amount_cents = event_procedure.procedure.amount_cents + apartment_amount + urgency_amount.to_i
    end

    private

    def apartment_amount
      return 0 unless event_procedure.apartment?

      event_procedure.procedure.amount_cents * APARTMENT_PERCENTAGE
    end

    def urgency_amount
      return 0 unless event_procedure.urgency?

      event_procedure.procedure.amount_cents * URGENCY_PERCENTAGE
    end
  end
end
