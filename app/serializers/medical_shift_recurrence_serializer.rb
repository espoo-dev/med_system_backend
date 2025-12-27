# frozen_string_literal: true

class MedicalShiftRecurrenceSerializer < ActiveModel::Serializer
  attributes :id,
    :frequency,
    :day_of_week,
    :day_of_month,
    :start_date,
    :end_date,
    :workload,
    :start_hour,
    :hospital_name,
    :amount_cents,
    :last_generated_until,
    :user_id,
    :color

  def amount_cents
    object.amount.format
  end

  def end_date
    object.end_date.strftime("%d/%m/%Y") if object.end_date.present?
  end

  def last_generated_until
    object.last_generated_until.strftime("%d/%m/%Y") if object.last_generated_until.present?
  end

  def start_date
    object.start_date.strftime("%d/%m/%Y")
  end

  def start_hour
    object.start_hour.strftime("%H:%M")
  end

  def workload
    object.workload_humanize
  end
end
