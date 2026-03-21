# frozen_string_literal: true

module EventProcedures
  module AssociationResolvable
    def find_or_create_patient(patient_attributes)
      Patients::FindOrCreate.result(params: patient_attributes).patient
    end

    def find_or_create_procedure(procedure_attributes)
      Procedures::FindOrCreate.result(params: procedure_attributes).procedure
    end

    def find_or_create_health_insurance(health_insurance_attributes)
      HealthInsurances::FindOrCreate.result(params: health_insurance_attributes).health_insurance
    end
  end
end
