# frozen_string_literal: true

module EventProcedures
  class SumAmountQuery < ApplicationQuery
    attr_reader :user_id, :month, :year, :payd

    def initialize(user_id:, month: nil, year: nil, payd: nil)
      @user_id = user_id
      @month = month
      @year = year
      @payd = payd
    end

    def call
      query = EventProcedure.where(user_id:)
      query = query.where("EXTRACT(MONTH FROM date) = ?", month) if month.present?
      query = query.where("EXTRACT(YEAR FROM date) = ?", year) if year.present?
      query = query.where(payd:) unless payd.nil?
      query.sum(:total_amount_cents)
    end
  end
end
