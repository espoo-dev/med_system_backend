# frozen_string_literal: true

module MedicalShifts
  class ByPaidQuery < ApplicationQuery
    attr_reader :paid, :relation

    def initialize(paid:, relation: MedicalShift)
      @paid = paid
      @relation = relation
    end

    def call
      paid == "true" ? relation.where(paid: true) : relation.where(paid: false)
    end
  end
end
