# frozen_string_literal: true

module MedicalShifts
  class HospitalNameSuggestion < Actor
    input :scope, type: Enumerable
    output :names, type: Array

    def call
      self.names = scope
        .distinct
        .order(:hospital_name)
        .pluck(:hospital_name)
    end
  end
end
