# frozen_string_literal: true

module MedicalShifts
  class TotalAmountCents < Actor
    output :total, type: String
    output :payd, type: String
    output :unpaid, type: String

    def call
      self.total = Money.new(MedicalShifts::SumTotalAmountQuery.call, "BRL").format
      self.payd = Money.new(MedicalShifts::SumPaydAmountQuery.call, "BRL").format
      self.unpaid = Money.new(MedicalShifts::SumUnpaidAmountQuery.call, "BRL").format
    end
  end
end
