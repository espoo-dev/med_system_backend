# frozen_string_literal: true

module MedicalShifts
  class Update < Actor
    input :id, type: String
    input :attributes, type: Hash

    output :medical_shift, type: MedicalShift

    def call
      self.medical_shift = find_medical_shift

      fail!(error: :invalid_record) unless medical_shift.update(attributes)
    end

    private

    def find_medical_shift
      MedicalShifts::Find.result(id: id).medical_shift
    end
  end
end
