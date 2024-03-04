# frozen_string_literal: true

class Procedure < ApplicationRecord
  monetize :amount

  has_many :event_procedures, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true
  validates :amount_cents, presence: true

  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }

  validates :code, uniqueness: { case_sensitive: false }
end
