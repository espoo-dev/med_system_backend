# frozen_string_literal: true

module EventProcedures
  class TotalAmountCents < Actor
    input :event_procedures

    output :total, type: String
    output :payd, type: String
    output :unpaid, type: String

    def call
      procedures_by_id = Procedure.where(id: event_procedures.pluck(:procedure_id)).index_by(&:id)

      self.total = calculate_amount(event_procedures, procedures_by_id)
      self.payd = calculate_amount(event_procedures.select(&:payd), procedures_by_id)
      self.unpaid = calculate_amount(event_procedures.reject(&:payd), procedures_by_id)
    end

    def convert_money(amount_cents)
      Money.new(amount_cents, "BRL").format
    end

    def calculate_amount(filtered_event_procedures, procedures_by_id)
      total_cents = filtered_event_procedures.sum do |event_procedure|
        procedures_by_id[event_procedure.procedure_id]&.amount_cents.to_i
      end
      convert_money(total_cents)
    end
  end
end
