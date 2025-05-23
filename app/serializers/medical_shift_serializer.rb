# frozen_string_literal: true

class MedicalShiftSerializer < ActiveModel::Serializer
  attributes :id, :hospital_name, :workload, :date, :hour, :amount_cents, :paid, :shift, :title

  def date
    object.start_date.strftime("%d/%m/%Y")
  end

  def hour
    object.start_hour.strftime("%H:%M")
  end

  def amount_cents
    object.amount.format
  end

  def workload
    object.workload_humanize
  end
end
