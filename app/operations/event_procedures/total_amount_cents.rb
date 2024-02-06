# frozen_string_literal: true

module EventProcedures
  class TotalAmountCents < Actor
    input :user_id, type: Integer

    output :total, type: String
    output :payd, type: String
    output :unpaid, type: String

    def call
      self.total = Money.new(EventProcedures::SumTotalAmountQuery.call(user_id: user_id), "BRL").format
      self.payd = Money.new(EventProcedures::SumPaydAmountQuery.call(user_id: user_id), "BRL").format
      self.unpaid = Money.new(EventProcedures::SumUnpaidAmountQuery.call(user_id: user_id), "BRL").format
    end
  end
end
