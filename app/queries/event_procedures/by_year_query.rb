# frozen_string_literal: true

module EventProcedures
  class ByYearQuery < ApplicationQuery
    attr_reader :year, :relation

    def initialize(year:, relation: EventProcedure)
      @year = year
      @relation = relation
    end

    def call
      relation.where("EXTRACT(YEAR FROM date) = ?", year)
    end
  end
end
