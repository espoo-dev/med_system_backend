# frozen_string_literal: true

module MedicalShifts
  class TotalAmountCents < Actor
    input :medical_shifts

    output :total, type: String
    output :paid, type: String
    output :unpaid, type: String

    def call
      self.total = Money.new(medical_shifts.sum(&:amount_cents), "BRL").format
      self.paid = Money.new(medical_shifts.select(&:paid).sum(&:amount_cents), "BRL").format
      self.unpaid = Money.new(medical_shifts.reject(&:paid).sum(&:amount_cents), "BRL").format
    end
  end
end
