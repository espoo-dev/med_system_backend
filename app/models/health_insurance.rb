# frozen_string_literal: true

class HealthInsurance < ApplicationRecord
  belongs_to :user, optional: true

  has_many :event_procedures, dependent: :destroy

  scope :by_custom, HealthInsurances::ByCustomQuery

  validates :name, presence: true
  validates :user_id, presence: true, if: :custom?

  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }

  def custom?
    custom == true
  end
end
