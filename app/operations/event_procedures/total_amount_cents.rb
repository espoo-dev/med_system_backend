# frozen_string_literal: true

module EventProcedures
  class TotalAmountCents < Actor
    input :event_procedures

    output :total, type: String
    output :payd, type: String
    output :unpaid, type: String

    def call
      self.total = calculate_amount(event_procedures)
      self.payd = calculate_amount(event_procedures.select(&:payd))
      self.unpaid = calculate_amount(event_procedures.reject(&:payd))
    end

    def convert_money(amount_cents)
      Money.new(amount_cents, "BRL").format
    end

    def calculate_amount(filtered_event_procedures)
      total_cents = filtered_event_procedures.sum do |event_procedure|
        result = BuildTotalAmountCents.call(event_procedure: event_procedure)
        result.total_amount_cents
      end
      convert_money(total_cents)
    end
  end
end
