# frozen_string_literal: true

class Cbhpm < ApplicationRecord
  validates :year, presence: true
  validates :name, presence: true
end
