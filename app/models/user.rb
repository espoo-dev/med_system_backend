# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable, :api,
    :omniauthable, omniauth_providers: %i[github strava]

  has_many :event_procedures, dependent: :destroy
  has_many :medical_shifts, dependent: :destroy
  has_many :patients, dependent: :destroy
  has_many :procedures, dependent: :destroy
  has_many :health_insurances, dependent: :destroy

  validates :email, uniqueness: { case_sensitive: false }
end
