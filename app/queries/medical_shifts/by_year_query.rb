# frozen_string_literal: true

module MedicalShifts
  class ByYearQuery < ApplicationQuery
    attr_reader :year, :relation

    def initialize(year:, relation: MedicalShift)
      @year = year
      @relation = relation
    end

    def call
      relation.where("EXTRACT(YEAR FROM start_date) = ?", year)
    end
  end
end
