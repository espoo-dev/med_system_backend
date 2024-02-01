# frozen_string_literal: true

module MedicalShifts
  class Create < Actor
    input :attributes, type: Hash

    output :medical_shift, type: MedicalShift

    def call
      self.medical_shift = MedicalShift.new(attributes)

      fail!(error: :invalid_record) unless medical_shift.save
    end
  end
end
