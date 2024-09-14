# frozen_string_literal: true

module MedicalShifts
  class SumPaydAmountQuery < ApplicationQuery
    attr_reader :user_id, :month, :relation

    def initialize(user_id:, month: nil, relation: MedicalShift)
      @user_id = user_id
      @month = month
      @relation = relation
    end

    def call
      query = relation.where(user_id:).where(payd: true)
      query = query.where("EXTRACT(MONTH FROM start_date) = ?", month) if month.present?
      query.sum(:amount_cents)
    end
  end
end
