# frozen_string_literal: true

module MedicalShifts
  class Create < Actor
    input :attributes, type: Hash
    input :user_id, type: Integer

    output :medical_shift, type: MedicalShift

    def call
      self.medical_shift = MedicalShift.new(attributes.reverse_merge(user_id: user_id))

      fail!(error: :invalid_record) unless medical_shift.save
    end
  end
end
