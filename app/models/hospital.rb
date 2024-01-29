# frozen_string_literal: true

class Hospital < ApplicationRecord
  has_many :event_procedures, dependent: :destroy
  has_many :medical_shifts, dependent: :destroy

  validates :name, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :address, uniqueness: { case_sensitive: false }
  validates :address, presence: true
end
