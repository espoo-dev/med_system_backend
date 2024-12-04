# frozen_string_literal: true

module EventProcedures
  class ByHealthInsuranceNameQuery < ApplicationQuery
    attr_reader :name, :relation

    def initialize(name:, relation: EventProcedure)
      @name = name
      @relation = relation
    end

    def call
      relation.joins(:health_insurance).where("health_insurances.name ILIKE ?", "%#{name}%")
    end
  end
end
