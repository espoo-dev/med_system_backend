# frozen_string_literal: true

module MedicalShifts
  class SumPaydAmountQuery < ApplicationQuery
    attr_reader :user_id, :relation

    def initialize(user_id:, relation: MedicalShift)
      @user_id = user_id
      @relation = relation
    end

    def call
      relation.where(user_id: user_id).where(payd: true).sum(:amount_cents)
    end
  end
end
