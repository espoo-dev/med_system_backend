# frozen_string_literal: true

module Patients
  class Find < Actor
    input :id, type: String

    output :patient, type: Patient

    def call
      self.patient = Patient.find(id)
    end
  end
end
