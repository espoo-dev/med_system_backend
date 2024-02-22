# frozen_string_literal: true

module Patients
  class FindOrCreate < Actor
    input :params, type: Hash, allow_nil: true

    output :patient, type: Patient

    def call
      self.patient = find_patient || create_patient
    end

    private

    def find_patient
      Patient.find_by(id: params[:id]) if params[:id]
    end

    def create_patient
      self.patient = Patient.new(name: params[:name])

      fail!(error: :invalid_record) unless patient.save

      patient
    end
  end
end
