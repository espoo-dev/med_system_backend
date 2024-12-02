# frozen_string_literal: true

module EventProcedures
  class ByHospitalNameQuery < ApplicationQuery
    attr_reader :hospital_name, :relation

    def initialize(hospital_name:, relation: EventProcedure)
      @hospital_name = hospital_name
      @relation = relation
    end

    def call
      relation.joins(:hospital).where("hospitals.name ILIKE ?", "%#{hospital_name}%")
    end
  end
end
