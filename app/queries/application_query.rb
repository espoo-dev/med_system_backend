# frozen_string_literal: true

class ApplicationQuery
  def self.call(...)
    new(...).call
  end

  def call
    raise "`call` method should be implemented in concrete class"
  end
end
