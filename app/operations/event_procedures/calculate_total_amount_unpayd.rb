# frozen_string_literal: true

module EventProcedures
  class CalculateTotalAmountUnpayd < Actor
    output :unpayd, type: String

    def call
      unpayd_amount_cents = EventProcedure.where(payd_at: nil).sum(:total_amount_cents)
      self.unpayd = Money.new(unpayd_amount_cents, "BRL").format
    end
  end
end
