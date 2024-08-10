# frozen_string_literal: true

module MedicalShifts
  class SumUnpaidAmountQuery < ApplicationQuery
    attr_reader :user_id, :relation

    def initialize(user_id:, relation: MedicalShift)
      @user_id = user_id
      @relation = relation
    end

    def call
      relation.where(user_id: user_id).where(payd: false).sum(:amount_cents)
    end
  end
end
