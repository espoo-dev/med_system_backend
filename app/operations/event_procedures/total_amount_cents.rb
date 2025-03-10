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
      procedures_by_id = {}
      user_procedures.each do |procedure|
        procedures_by_id[procedure.id] = procedure
      end
      total = 0
      event_procedures.each do |event_procedure|
        procedure = procedures_by_id[event_procedure.procedure_id]
        total += procedure.amount_cents if procedure
      end
      convert_money(total)
    end

    def calculate_payd(user_procedures)
      procedures_by_id = {}
      user_procedures.each do |procedure|
        procedures_by_id[procedure.id] = procedure
      end
      total = 0
      event_procedures.select(&:payd).each do |event_procedure|
        procedure = procedures_by_id[event_procedure.procedure_id]
        total += procedure.amount_cents if procedure
      end
      convert_money(total)
    end

    def calculate_unpayd(user_procedures)
      procedures_by_id = {}
      user_procedures.each do |procedure|
        procedures_by_id[procedure.id] = procedure
      end
      total = 0
      event_procedures.reject(&:payd).each do |event_procedure|
        procedure = procedures_by_id[event_procedure.procedure_id]
        total += procedure.amount_cents if procedure
      end
      convert_money(total)
    end
  end
end
