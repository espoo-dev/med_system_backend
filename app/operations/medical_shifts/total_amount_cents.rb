# frozen_string_literal: true

module MedicalShifts
  class TotalAmountCents < Actor
    input :medical_shifts

    output :total, type: String
    output :paid, type: String
    output :unpaid, type: String

    def call
      self.total = formatted_amount(medical_shifts.sum(&:amount_cents))
      self.paid = formatted_amount(medical_shifts.select(&:paid).sum(&:amount_cents))
      self.unpaid = formatted_amount(medical_shifts.reject(&:paid).sum(&:amount_cents))
    end

    private

    def formatted_amount(value)
      Money.new(value, "BRL").format(thousands_separator: ".", decimal_mark: ",")
    end
  end
end
