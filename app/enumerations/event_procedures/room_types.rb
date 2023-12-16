# frozen_string_literal: true

module EventProcedures
  class RoomTypes < EnumerateIt::Base
    associate_values(
      :ward,
      :apartment
    )
  end
end
