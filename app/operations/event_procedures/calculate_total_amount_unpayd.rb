# frozen_string_literal: true

module EventProcedures
  class CalculateTotalAmountUnpayd < Actor
    output :unpayd, type: String

    def call
      unpayd_amount_cents = EventProcedure.joins(:procedure).where(payd_at: nil).sum("procedures.amount_cents")
      self.unpayd = Money.new(unpayd_amount_cents, "BRL").format
    end
  end
end
