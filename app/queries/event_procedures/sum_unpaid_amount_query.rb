# frozen_string_literal: true

module EventProcedures
  class SumUnpaidAmountQuery < ApplicationQuery
    attr_reader :user_id, :month, :relation

    def initialize(user_id:, month: nil, relation: EventProcedure)
      @user_id = user_id
      @month = month
      @relation = relation
    end

    def call
      query = relation.where(user_id: user_id)
      query = query.where(payd_at: nil)
      query = query.where("EXTRACT(MONTH FROM date) = ?", month) if month.present?
      query.sum(:total_amount_cents)
    end
  end
end
