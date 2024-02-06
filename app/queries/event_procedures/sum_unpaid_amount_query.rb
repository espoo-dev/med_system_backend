# frozen_string_literal: true

module EventProcedures
  class SumUnpaidAmountQuery < ApplicationQuery
    attr_reader :user_id, :relation

    def initialize(user_id:, relation: EventProcedure)
      @user_id = user_id
      @relation = relation
    end

    def call
      relation.where(user_id: user_id).where(payd_at: nil).sum(:total_amount_cents)
    end
  end
end
