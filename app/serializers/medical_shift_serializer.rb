# frozen_string_literal: true

class MedicalShiftSerializer < ActiveModel::Serializer
  attributes :id, :hospital_name, :workload, :date, :hour, :amount_cents, :payd, :shift, :title

  delegate :shift, to: :object
  delegate :title, to: :object

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
