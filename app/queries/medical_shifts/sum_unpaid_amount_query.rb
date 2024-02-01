# frozen_string_literal: true

module MedicalShifts
  class SumUnpaidAmountQuery < ApplicationQuery
    attr_reader :relation

    def initialize(relation: MedicalShift)
      @relation = relation
    end

    def call
      relation.where(was_paid: false).sum(:amount_cents)
    end
  end
end
