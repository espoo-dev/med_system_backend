# frozen_string_literal: true

class MedicalShift < ApplicationRecord
  acts_as_paranoid

  has_enumeration_for :workload, with: MedicalShifts::Workloads, create_helpers: true

  monetize :amount

  belongs_to :user
  belongs_to :medical_shift_recurrence, optional: true

  scope :by_hospital, MedicalShifts::ByHospitalQuery
  scope :by_month, MedicalShifts::ByMonthQuery
  scope :by_year, MedicalShifts::ByYearQuery
  scope :by_paid, MedicalShifts::ByPaidQuery

  validates :workload, presence: true
  validates :start_date, presence: true
  validates :start_hour, presence: true
  validates :amount_cents, presence: true

  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :color, format: { with: /\A#[a-fA-F0-9]{6}\z/ }

  def shift
    daytime_start = Time.new(2000, 0o1, 0o1, 0o7, 0o0, 0o0, 0o0)
    daytime_finish = Time.new(2000, 0o1, 0o1, 18, 59, 0o0, 0o0)

    return I18n.t("medical_shifts.attributes.shift.daytime") if start_hour.between?(daytime_start, daytime_finish)

    I18n.t("medical_shifts.attributes.shift.nighttime")
  end

  def title
    "#{hospital_name} | #{workload_humanize} | #{shift}"
  end

  def recurring?
    medical_shift_recurrence_id.present?
  end

  def formatted_amount
    amount.format(thousands_separator: ".", decimal_mark: ",")
  end
end
