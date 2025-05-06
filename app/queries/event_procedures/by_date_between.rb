# frozen_string_literal: true

module EventProcedures
  class ByDateBetween < ApplicationQuery
    attr_reader :start_date, :end_date

    def initialize(start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
    end

    def call
      EventProcedure.where(date: start_date..end_date)
    end
  end
end
