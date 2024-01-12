# frozen_string_literal: true

class EventProcedure < ApplicationRecord
  has_enumeration_for :room_type, with: EventProcedures::RoomTypes, create_helpers: true

  monetize :total_amount

  belongs_to :health_insurance
  belongs_to :hospital
  belongs_to :patient
  belongs_to :procedure

  validates :date, presence: true
  validates :patient_service_number, presence: true
  validates :room_type, presence: true
end
