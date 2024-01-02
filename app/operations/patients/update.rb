# frozen_string_literal: true

module Patients
  class Update < Actor
    input :id, type: String
    input :attributes, type: Hash

    output :patient, type: Patient

    def call
      self.patient = find_patient

      fail!(error: :invalid_record) unless patient.update(attributes)
    end

    private

    def find_patient
      Patients::Find.result(id: id).patient
    end
  end
end
