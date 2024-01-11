# frozen_string_literal: true

module EventProcedures
  class TotalAmountCents < Actor
    play EventProcedures::CalculateTotalAmount,
      EventProcedures::CalculateTotalAmountPayd,
      EventProcedures::CalculateTotalAmountUnpayd
  end
end
