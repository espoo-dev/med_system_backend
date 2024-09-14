# frozen_string_literal: true

module MedicalShifts
  class TotalAmountCents < Actor
    input :user_id, type: Integer
    input :month, type: String, allow_nil: true

    output :total, type: String
    output :payd, type: String
    output :unpaid, type: String

    def call
      self.total = Money.new(MedicalShifts::SumTotalAmountQuery.call(user_id:, month:), "BRL").format
      self.payd = Money.new(MedicalShifts::SumPaydAmountQuery.call(user_id:, month:), "BRL").format
      self.unpaid = Money.new(MedicalShifts::SumUnpaidAmountQuery.call(user_id:, month:), "BRL").format
    end
  end
end
