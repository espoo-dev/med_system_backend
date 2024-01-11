# frozen_string_literal: true

module EventProcedures
  class CalculateTotalAmount < Actor
    output :total, type: String

    def call
      total_amount_cents = EventProcedure.joins(:procedure).sum("procedures.amount_cents")
      self.total = Money.new(total_amount_cents, "BRL").format
    end
  end
end