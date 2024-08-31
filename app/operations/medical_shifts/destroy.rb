# frozen_string_literal: true

module MedicalShifts
  class Destroy < Actor
    input :id, type: String
    output :medical_shift, type: MedicalShift

    def call
      self.medical_shift = MedicalShift.find(id)

      fail!(error: :cannot_destroy) unless medical_shift.destroy
    end
  end
end
