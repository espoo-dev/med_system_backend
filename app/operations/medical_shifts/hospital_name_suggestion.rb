# frozen_string_literal: true

module MedicalShifts
  class HospitalNameSuggestion < Actor
    output :names, type: Array

    def call
      self.names = MedicalShift.select(:hospital_name).distinct.order(:hospital_name).pluck(:hospital_name)
    end
  end
end
