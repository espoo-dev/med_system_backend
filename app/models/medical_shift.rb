# frozen_string_literal: true

class MedicalShift < ApplicationRecord
  has_enumeration_for :workload, with: MedicalShifts::Workloads, create_helpers: true

  monetize :amount

  belongs_to :hospital

  validates :workload, presence: true
  validates :date, presence: true
  validates :amount_cents, presence: true

  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }
end
