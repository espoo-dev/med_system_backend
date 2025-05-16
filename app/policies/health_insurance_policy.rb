# frozen_string_literal: true

class HealthInsurancePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user.present?
  end
end
