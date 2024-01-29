# frozen_string_literal: true

module MedicalShifts
  class Workloads < EnumerateIt::Base
    associate_values(
      :six,
      :twelve,
      :twenty_four
    )
  end
end
