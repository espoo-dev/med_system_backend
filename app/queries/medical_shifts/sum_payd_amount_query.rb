# frozen_string_literal: true

module MedicalShifts
  class SumPaydAmountQuery < ApplicationQuery
    attr_reader :relation

    def initialize(relation: MedicalShift)
      @relation = relation
    end

    def call
      relation.where(was_paid: true).sum(:amount_cents)
    end
  end
end
