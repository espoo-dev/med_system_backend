# frozen_string_literal: true

module MedicalShifts
  class ByPaydQuery < ApplicationQuery
    attr_reader :payd, :relation

    def initialize(payd:, relation: MedicalShift)
      @payd = payd
      @relation = relation
    end

    def call
      payd == "true" ? relation.where(payd: true) : relation.where(payd: false)
    end
  end
end
