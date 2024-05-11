# frozen_string_literal: true

class Cbhpm < ApplicationRecord
  has_many :port_values, dependent: :destroy

  validates :year, presence: true
  validates :name, presence: true
end
