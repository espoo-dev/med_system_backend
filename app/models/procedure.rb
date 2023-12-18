# frozen_string_literal: true

class Procedure < ApplicationRecord
  has_many :event_procedures, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true
end
