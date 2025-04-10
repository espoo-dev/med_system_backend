# frozen_string_literal: true

module EventProcedures
  class ByPaidQuery < ApplicationQuery
    attr_reader :paid, :relation

    def initialize(paid:, relation: EventProcedure)
      @paid = paid
      @relation = relation
    end

    def call
      paid == "true" ? relation.where(paid: true) : relation.where(paid: false)
    end
  end
end
