# frozen_string_literal: true

class MedicalShiftSerializer < ActiveModel::Serializer
  attributes :id, :hospital_name, :workload, :date, :amount_cents, :was_paid

  def hospital_name
    object.hospital.name
  end

  def date
    object.date.strftime("%d/%m/%Y")
  end
end
