# frozen_string_literal: true

module MedicalShifts
  class AmountSuggestion < Actor
    input :scope, type: Enumerable
    output :amounts_cents, type: Array

    def call
      self.amounts_cents = scope
        .distinct
        .order(:amount_cents)
        .pluck(:amount_cents)
        .map do |amount|
          Money.new(amount, "BRL").format
        end
    end
  end
end
