# frozen_string_literal: true

module MedicalShifts
  class TotalAmountCents < Actor
    input :medical_shifts

    output :total, type: String
    output :payd, type: String
    output :unpaid, type: String

    def call
      self.total = Money.new(medical_shifts.sum(&:amount_cents), "BRL").format
      self.payd = Money.new(medical_shifts.select(&:payd).sum(&:amount_cents), "BRL").format
      self.unpaid = Money.new(medical_shifts.reject(&:payd).sum(&:amount_cents), "BRL").format
    end
  end
end
