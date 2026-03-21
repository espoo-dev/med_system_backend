# frozen_string_literal: true

module Patients
  class Destroy < Actor
    input :id, type: String
    input :scope, type: Enumerable, default: -> { Patient.all }

    output :patient, type: Patient

    def call
      self.patient = scope.find(id)

      fail!(error: :cannot_destroy) unless patient.destroy
    end
  end
end
