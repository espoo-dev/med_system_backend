# frozen_string_literal: true

class EventProcedureSerializer < ActiveModel::Serializer
  attributes :id, :procedure, :patient, :hospital, :health_insurance, :patient_service_number, :date,
    :room_type, :urgency, :payd_at, :total_amount_cents

  def total_amount_cents
    object.total_amount.format
  end

  def procedure
    object.procedure.name
  end

  def patient
    object.patient.name
  end

  def hospital
    object.hospital.name
  end

  def health_insurance
    object.health_insurance.name
  end

  def date
    object.date.strftime("%d/%m/%Y")
  end

  def payd_at
    object.payd_at&.strftime("%d/%m/%Y")
  end
end
