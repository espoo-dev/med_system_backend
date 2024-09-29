# frozen_string_literal: true

module EventProcedures
  class TotalAmountCents < Actor
    input :user_id, type: Integer
    input :month, type: String, allow_nil: true

    output :total, type: String
    output :payd, type: String
    output :unpaid, type: String

    def call
      self.total = calculate_total
      self.payd = calculate_paid
      self.unpaid = calculate_unpaid
    end

    private

    def calculate_total
      Money.new(SumAmountQuery.call(user_id:, month:, year:), "BRL").format
    end

    def calculate_paid
      Money.new(SumAmountQuery.call(user_id:, month:, year:, payd: true), "BRL").format
    end

    def calculate_unpaid
      Money.new(SumAmountQuery.call(user_id:, month:, year:, payd: false), "BRL").format
    end
  end
end
