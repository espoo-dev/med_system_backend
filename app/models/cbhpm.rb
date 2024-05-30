# frozen_string_literal: true

class Cbhpm < ApplicationRecord
  has_many :cbhpm_procedures, dependent: :destroy
  has_many :event_procedures, dependent: :destroy
  has_many :port_values, dependent: :destroy
  has_many :procedures, through: :cbhpm_procedures

  validates :year, presence: true
  validates :name, presence: true
end
