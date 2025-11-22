# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable, :api,
    :omniauthable, :confirmable, :lockable,
    omniauth_providers: %i[github strava google_oauth2]

  has_many :event_procedures, dependent: :destroy
  has_many :medical_shifts, dependent: :destroy
  has_many :medical_shift_recurrences, dependent: :destroy
  has_many :patients, dependent: :destroy
  has_many :procedures, dependent: :destroy
  has_many :health_insurances, dependent: :destroy

  validates :email, uniqueness: { case_sensitive: false }
end
