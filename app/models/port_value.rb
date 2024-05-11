# frozen_string_literal: true

class PortValue < ApplicationRecord
  monetize :amount

  belongs_to :cbhpm

  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }
end
