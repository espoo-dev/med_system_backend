# frozen_string_literal: true

class EventProcedureSerializer < ActiveModel::Serializer
  attributes :id, :procedure, :patient, :hospital, :health_insurance, :patient_service_number, :date,
    :room_type, :urgency, :payd_at

  DATE_ATTRIBUTES = %i[date payd_at].freeze

  DATE_ATTRIBUTES.each do |date_attribute|
    define_method(date_attribute) do
      object.public_send(date_attribute)&.strftime("%d/%m/%Y")
    end
  end

  def procedure
    ProcedureSerializer.new(object.procedure)
  end

  def patient
    PatientSerializer.new(object.patient)
  end

  def hospital
    HospitalSerializer.new(object.hospital)
  end

  def health_insurance
    HealthInsuranceSerializer.new(object.health_insurance)
  end
end
