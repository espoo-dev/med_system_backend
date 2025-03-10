# frozen_string_literal: true

module EventProcedures
  class TotalAmountCents < Actor
    input :event_procedures

    output :total, type: String
    output :payd, type: String
    output :unpaid, type: String

    def call
      procedures = Procedure.where(id: event_procedures.pluck(:procedure_id))

      self.total = calculate_total(procedures)
      self.payd = calculate_payd(procedures)
      self.unpaid = calculate_unpayd(procedures)
    end

    def convert_money(amount_cents)
      Money.new(amount_cents, "BRL").format
    end

    def calculate_total(user_procedures)
      convert_money(user_procedures.sum(&:amount_cents))
    end

    def calculate_payd(user_procedures)
      payd_procedures_ids = event_procedures.select(&:payd).pluck(:procedure_id)
      payd_procedures = user_procedures.where(id: payd_procedures_ids)
      convert_money(payd_procedures.sum(&:amount_cents))
    end

    def calculate_unpayd(user_procedures)
      unpayd_procudures_ids = event_procedures.reject(&:payd).pluck(:procedure_id)
      unpayd_procudures = user_procedures.where(id: unpayd_procudures_ids)
      convert_money(unpayd_procudures.sum(&:amount_cents))
    end
  end
end
