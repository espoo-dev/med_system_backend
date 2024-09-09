# frozen_string_literal: true

module MedicalShifts
  class HospitalNameSuggestion < Actor
    input :user_id, type: Integer
    output :names, type: Array

    def call
      self.names = MedicalShift.where(user_id: user_id)
        .select(:hospital_name)
        .distinct
        .order(:hospital_name)
        .pluck(:hospital_name)
    end
  end
end
