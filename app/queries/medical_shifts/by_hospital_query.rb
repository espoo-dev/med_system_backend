# frozen_string_literal: true

module MedicalShifts
  class ByHospitalQuery < ApplicationQuery
    attr_reader :hospital_name, :relation

    def initialize(hospital_name:, relation: MedicalShift)
      @hospital_name = hospital_name
      @relation = relation
    end

    def call
      relation.where(hospital_name: hospital_name)
    end
  end
end
