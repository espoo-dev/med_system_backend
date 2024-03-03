# frozen_string_literal: true

class Patient < ApplicationRecord
  has_many :event_procedures, dependent: :destroy
  belongs_to :user

  validates :name, presence: true
end
