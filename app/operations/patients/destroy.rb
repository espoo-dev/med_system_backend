# frozen_string_literal: true

module Patients
  class Destroy < Actor
    input :id, type: String

    output :patient, type: Patient

    def call
      self.patient = Patient.find(id)

      fail!(error: :cannot_destroy) unless patient.destroy
    end
  end
end
