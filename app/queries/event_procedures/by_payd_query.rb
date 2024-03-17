# frozen_string_literal: true

module EventProcedures
  class ByPaydQuery < ApplicationQuery
    attr_reader :payd, :relation

    def initialize(payd:, relation: EventProcedure)
      @payd = payd
      @relation = relation
    end

    def call
      payd == "true" ? relation.where(payd: true) : relation.where(payd: false)
    end
  end
end
