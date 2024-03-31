# frozen_string_literal: true

class Procedure < ApplicationRecord
  monetize :amount

  belongs_to :user, optional: true

  has_many :event_procedures, dependent: :destroy

  scope :by_custom, Procedures::ByCustomQuery

  validates :name, presence: true
  validates :code, presence: true
  validates :amount_cents, presence: true
  validates :user_id, presence: true, if: :custom?

  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }

  validates :code, uniqueness: { case_sensitive: false }

  def custom?
    custom == true
  end
end
