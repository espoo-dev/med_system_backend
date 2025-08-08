# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :api,
    :omniauthable, :confirmable, :lockable,
    omniauth_providers: %i[github strava google_oauth2]

  has_many :event_procedures, dependent: :destroy
  has_many :medical_shifts, dependent: :destroy
  has_many :patients, dependent: :destroy
  has_many :procedures, dependent: :destroy
  has_many :health_insurances, dependent: :destroy

  validates :email, presence: true,
    format: { with: Devise.email_regexp },
    uniqueness: {
      case_sensitive: false,
      conditions: -> { where(deleted_at: nil) }
    }

  validates :password, presence: true, length: { minimum: 6 }, confirmation: true, if: :password_required?

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
