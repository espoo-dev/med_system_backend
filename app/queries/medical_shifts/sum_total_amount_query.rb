# frozen_string_literal: true

module MedicalShifts
  class SumTotalAmountQuery < ApplicationQuery
    attr_reader :relation

    def initialize(relation: MedicalShift)
      @relation = relation
    end

    def call
      relation.sum(:amount_cents)
    end
  end
end
