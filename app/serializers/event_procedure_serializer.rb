# frozen_string_literal: true

class EventProcedureSerializer < ActiveModel::Serializer
  attributes :id, :procedure_id, :patient_id, :hospital_id, :health_insurance_id, :patient_service_number, :date,
    :room_type, :urgency, :payd_at
end
