# frozen_string_literal: true

module Patients
  class Find < Actor
    input :id, type: String
    input :scope, type: Enumerable, default: -> { Patient.all }

    output :patient, type: Patient

    def call
      self.patient = scope.find(id)
    end
  end
end
