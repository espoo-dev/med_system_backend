# frozen_string_literal: true

module EventProcedures
  class ByMonthQuery < ApplicationQuery
    attr_reader :month, :relation

    def initialize(month:, relation: EventProcedure)
      @month = month
      @relation = relation
    end

    def call
      relation.where("EXTRACT(MONTH FROM date) = ?", month)
    end
  end
end
