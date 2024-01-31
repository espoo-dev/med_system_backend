# frozen_string_literal: true

module MedicalShifts
  class ByHospitalQuery < ApplicationQuery
    attr_reader :hospital_id, :relation

    def initialize(hospital_id:, relation: MedicalShift)
      @hospital_id = hospital_id
      @relation = relation
    end

    def call
      relation.where(hospital_id: hospital_id)
    end
  end
end
