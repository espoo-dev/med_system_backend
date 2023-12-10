# frozen_string_literal: true

class Hospital < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
  validates :address, uniqueness: { case_sensitive: false }
end
