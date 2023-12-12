# frozen_string_literal: true

class Procedure < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true
end
