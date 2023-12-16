# frozen_string_literal: true

class EventProcedure < ApplicationRecord
  has_enumeration_for :room_type, with: EventProcedures::RoomTypes, create_helpers: true
  monetize :amount

  belongs_to :health_insurance
  belongs_to :hospital
  belongs_to :patient
  belongs_to :procedure

  validates :amount_cents, presence: true
  validates :date, presence: true
  validates :patient_service_number, presence: true
  validates :room_type, presence: true

  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }
end
