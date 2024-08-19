# frozen_string_literal: true

class Hospital < ApplicationRecord
  has_many :event_procedures, dependent: :destroy

  validates :name, presence: true
  validates :address, presence: true

  validates :name, uniqueness: { case_sensitive: false }
end
