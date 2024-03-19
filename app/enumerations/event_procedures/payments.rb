# frozen_string_literal: true

module EventProcedures
  class Payments < EnumerateIt::Base
    associate_values(
      :health_insurance,
      :others
    )
  end
end
