# frozen_string_literal: true

class HealthInsurancePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user_owner?
  end
end
