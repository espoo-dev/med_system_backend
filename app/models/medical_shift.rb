# frozen_string_literal: true

class MedicalShift < ApplicationRecord
  has_enumeration_for :workload, with: MedicalShifts::Workloads, create_helpers: true

  monetize :amount

  belongs_to :user

  scope :by_hospital, MedicalShifts::ByHospitalQuery
  scope :by_month, MedicalShifts::ByMonthQuery
  scope :by_payd, MedicalShifts::ByPaydQuery

  validates :workload, presence: true
  validates :start_date, presence: true
  validates :start_hour, presence: true
  validates :amount_cents, presence: true

  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }

  before_create :parsed_shift
  before_save :parsed_title # rubocop:disable Rails/ActiveRecordCallbacksOrder

  def parsed_shift
    daytime_start = Time.new(2000, 0o1, 0o1, 0o7, 0o0, 0o0, 0o0)
    daytime_finish = Time.new(2000, 0o1, 0o1, 18, 59, 0o0, 0o0)

    if start_hour.between?(daytime_start, daytime_finish)
      return self.shift = I18n.t("medical_shifts.attributes.shift.daytime")
    end

    self.shift = I18n.t("medical_shifts.attributes.shift.nighttime")
  end

  def parsed_title
    self.title = "#{hospital_name} | #{workload_humanize} | #{parsed_shift}"
  end
end
