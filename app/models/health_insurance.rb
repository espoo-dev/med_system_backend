# frozen_string_literal: true

class HealthInsurance < ApplicationRecord
  validates :name, presence: true
end
