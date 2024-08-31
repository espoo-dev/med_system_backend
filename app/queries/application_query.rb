# frozen_string_literal: true

class ApplicationQuery
  def self.call(...)
    new(...).call
  end

  def call
    raise "`call` method should be implemented in concrete class"
  end

  def range_all_year(year)
    range_year = Date.new(year.to_i).all_year

    range_year.first.beginning_of_day..range_year.last.end_of_day
  end
end
