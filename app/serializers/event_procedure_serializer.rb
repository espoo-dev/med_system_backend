# frozen_string_literal: true

class EventProcedureSerializer < ActiveModel::Serializer
  attributes :id, :cbhpm_id, :procedure, :patient, :hospital, :health_insurance, :patient_service_number, :date,
    :room_type, :payment, :urgency, :payd, :total_amount_cents, :precedure_value, :precedure_description

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

  def precedure_value
    object.procedure.amount.format
  end

  def precedure_description
    object.procedure.description
  end
end
