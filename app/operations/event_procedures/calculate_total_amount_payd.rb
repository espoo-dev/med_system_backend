# frozen_string_literal: true

module EventProcedures
  class CalculateTotalAmountPayd < Actor
    output :payd, type: String

    def call
      payd_amount_cents = EventProcedure.joins(:procedure).where.not(payd_at: nil).sum("procedures.amount_cents")
      self.payd = Money.new(payd_amount_cents, "BRL").format
    end
  end
end
