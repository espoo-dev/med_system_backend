# frozen_string_literal: true

module MedicalShifts
  class ByYearQuery < ApplicationQuery
    attr_reader :year, :relation

    def initialize(year:, relation: MedicalShift)
      @year = year
      @relation = relation
    end

    def call
      relation.where(start_date: range_all_year(year))
    end
  end
end
