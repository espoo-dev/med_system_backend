# frozen_string_literal: true

module MedicalShifts
  class Find < Actor
    input :id, type: String

    output :medical_shift, type: MedicalShift

    def call
      self.medical_shift = MedicalShift.find(id)
    end
  end
end
