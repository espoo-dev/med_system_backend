# frozen_string_literal: true

class HealthInsurance < ApplicationRecord
  has_many :event_procedures, dependent: :destroy

  validates :name, presence: true
end
