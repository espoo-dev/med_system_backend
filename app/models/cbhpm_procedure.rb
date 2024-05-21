# frozen_string_literal: true

class CbhpmProcedure < ApplicationRecord
  belongs_to :cbhpm
  belongs_to :procedure

  validates :port, presence: true
  validates :anesthetic_port, presence: true
end
