# frozen_string_literal: true

module MedicalShifts
  class Update < Actor
    input :id, type: String
    input :attributes, type: Hash

    output :medical_shift, type: MedicalShift

    def call
      self.medical_shift = MedicalShift.find(id)

      fail!(error: :invalid_record) unless medical_shift.update(attributes)
    end
  end
end
