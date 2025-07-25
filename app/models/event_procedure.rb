# frozen_string_literal: true

class EventProcedure < ApplicationRecord
  acts_as_paranoid

  has_enumeration_for :room_type, with: EventProcedures::RoomTypes, create_helpers: true
  has_enumeration_for :payment, with: EventProcedures::Payments, create_helpers: true

  has_many :port_values, through: :cbhpm

  monetize :total_amount

  belongs_to :cbhpm
  belongs_to :health_insurance
  belongs_to :hospital
  belongs_to :patient
  belongs_to :procedure
  belongs_to :user

  accepts_nested_attributes_for :patient
  accepts_nested_attributes_for :procedure
  accepts_nested_attributes_for :health_insurance

  scope :by_month, EventProcedures::ByMonthQuery
  scope :by_paid, EventProcedures::ByPaidQuery
  scope :by_year, EventProcedures::ByYearQuery
  scope :date_between, EventProcedures::ByDateBetween
  scope :by_hospital_name, EventProcedures::ByHospitalNameQuery
  scope :by_health_insurance_name, EventProcedures::ByHealthInsuranceNameQuery

  validates :date, presence: true
  validates :patient_service_number, presence: true
  validates :room_type, presence: true, if: -> { health_insurance? }
  validates :urgency, inclusion: [true, false], if: -> { health_insurance? }
  validates :payment, presence: true

  validate :match_user_with_patient_user
  validate :custom_and_urgency_cannot_be_true

  private

  def match_user_with_patient_user
    return if patient.nil? || user.nil?
    return if patient.user_id == user_id

    errors.add(:base, "The patient must be associated with the same procedure user")
  end

  def custom_and_urgency_cannot_be_true
    return unless procedure&.custom && urgency

    errors.add(:base, "Custom procedures can't be urgent")
  end
end
