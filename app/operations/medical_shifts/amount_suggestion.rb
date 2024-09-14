# frozen_string_literal: true

module MedicalShifts
  class AmountSuggestion < Actor
    input :scope, type: Enumerable
    output :amounts, type: Array

    def call
      self.amounts = scope
        .distinct
        .order(:amount_cents)
        .pluck(:amount_cents)
    end
  end
end
