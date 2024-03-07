# frozen_string_literal: true

class Patient < ApplicationRecord
  has_many :event_procedures, dependent: :restrict_with_exception
  belongs_to :user

  validates :name, presence: true

  def deletable?
    event_procedures.empty?
  end
end
