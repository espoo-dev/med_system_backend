# frozen_string_literal: true

module Patients
  class Create < Actor
    input :attributes, type: Hash

    output :patient, type: Patient

    def call
      self.patient = Patient.new(attributes)

      fail!(error: :invalid_record) unless patient.save
    end
  end
end
