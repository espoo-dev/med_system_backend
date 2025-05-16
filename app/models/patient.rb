# frozen_string_literal: true

class Patient < ApplicationRecord
  acts_as_paranoid

  has_many :event_procedures, dependent: :destroy
  belongs_to :user

  validates :name, presence: true

  def name=(value)
    super(value&.strip)
  end

  def deletable?
    event_procedures.empty?
  end
end
