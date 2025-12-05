# frozen_string_literal: true

class MedicalShiftRecurrence < ApplicationRecord
  acts_as_paranoid

  FREQUENCIES = %w[weekly biweekly monthly_fixed_day].freeze

  has_enumeration_for :workload, with: MedicalShifts::Workloads, create_helpers: true

  monetize :amount

  belongs_to :user

  has_many :medical_shifts, dependent: :nullify

  validates :frequency, presence: true, inclusion: { in: FREQUENCIES }
  validates :start_date, presence: true
  validates :workload, presence: true
  validates :start_hour, presence: true
  validates :hospital_name, presence: true
  validates :amount_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :day_of_week, presence: true, if: lambda {
                                                frequency.in?(%w[weekly biweekly])
                                              }, numericality: { only_integer: true, in: 0..6 }
  validates :day_of_month, presence: true, if: lambda {
                                                 frequency == "monthly_fixed_day"
                                               }, numericality: { only_integer: true, in: 1..31 }

  validate :day_of_month_blank_for_weekly
  validate :day_of_week_blank_for_monthly
  validate :end_date_after_start_date

  scope :active, -> { where(deleted_at: nil) }
  scope :needs_generation, MedicalShiftRecurrences::NeedsGenerationQuery

  private

  def day_of_month_blank_for_weekly
    return unless frequency.in?(%w[weekly biweekly]) && day_of_month.present?

    errors.add(:day_of_month, "It must be empty for weekly/biweekly recurrence.")
  end

  def day_of_week_blank_for_monthly
    return unless frequency == "monthly_fixed_day" && day_of_week.present?

    errors.add(:day_of_week, "It must be empty for monthly_fixed_day recurrence.")
  end

  def end_date_after_start_date
    return unless end_date.present? && start_date.present? && end_date < start_date

    errors.add(:end_date, "End date must be after start date.")
  end
end
