# frozen_string_literal: true

module MedicalShifts
  class Find < Actor
    input :id, type: String
    input :scope, type: Enumerable, default: -> { MedicalShift.all }

    output :medical_shift, type: MedicalShift

    def call
      self.medical_shift = scope.find(id)
    end
  end
end
