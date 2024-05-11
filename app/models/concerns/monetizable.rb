# frozen_string_literal: true

module Monetizable
  def monetize(attribute)
    define_method attribute do
      cents = public_send(:"#{attribute}_cents")

      Money.new(cents)
    end
  end
end
