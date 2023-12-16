# frozen_string_literal: true

class EventProcedureSerializer < ActiveModel::Serializer
  attributes :id, :procedure, :patient, :hospital, :health_insurance, :patient_service_number, :date,
    :room_type, :amount, :urgency, :payd_at

  DATE_ATTRIBUTES = %i[date payd_at].freeze

  EventProcedure::ASSOCIATIONS.each do |association|
    define_method(association) do
      object.public_send(association).name
    end
  end

  DATE_ATTRIBUTES.each do |date_attribute|
    define_method(date_attribute) do
      object.public_send(date_attribute)&.strftime("%d/%m/%Y")
    end
  end

  def amount
    object.amount.format
  end
end
