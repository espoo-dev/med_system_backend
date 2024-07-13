# frozen_string_literal: true

class Patient < ApplicationRecord
  has_many :event_procedures, dependent: :restrict_with_exception
  belongs_to :user

  validates :name, presence: true

  before_save :remove_name_whitespace

  def deletable?
    event_procedures.empty?
  end

  private

  def remove_name_whitespace
    self.name = name.strip
  end
end
