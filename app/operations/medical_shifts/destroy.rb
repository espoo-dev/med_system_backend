# frozen_string_literal: true

module MedicalShifts
  class Destroy < Actor
    input :id, type: String
    input :scope, type: Enumerable, default: -> { MedicalShift.all }
    output :medical_shift, type: MedicalShift

    def call
      self.medical_shift = scope.find(id)

      fail!(error: :cannot_destroy) unless medical_shift.destroy
    end
  end
end
