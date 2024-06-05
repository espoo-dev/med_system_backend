# frozen_string_literal: true

class EventProcedureSerializer < ActiveModel::Serializer
  attributes :id, :cbhpm_id, :procedure, :patient, :hospital, :health_insurance, :patient_service_number, :date,
    :room_type, :payment, :urgency, :payd, :total_amount_cents, :procedure_value, :procedure_description

  def total_amount_cents
    object.total_amount.format
  end

  def procedure
    object.try(:procedure_name) || object.procedure.name
  end

  def patient
    object.try(:patient_name) || object.patient.name
  end

  def hospital
    object.try(:hospital_name) || object.hospital.name
  end

  def health_insurance
    object.try(:health_insurance_name) || object.health_insurance.name
  end

  def date
    object.date.strftime("%d/%m/%Y")
  end

  def procedure_value
    if object.try(:procedure_amount_cents)
      Money.new(object.procedure_amount_cents).format
    else
      object.procedure.amount.format
    end
  end

  def procedure_description
    object.try(:procedure_description) || object.procedure.description
  end
end
