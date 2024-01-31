# frozen_string_literal: true

module MedicalShifts
  class ByMonthQuery < ApplicationQuery
    attr_reader :month, :relation

    def initialize(month:, relation: MedicalShift)
      @month = month
      @relation = relation
    end

    def call
      relation.where("EXTRACT(MONTH FROM date) = ?", month)
    end
  end
end
