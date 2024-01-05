# frozen_string_literal: true

class HospitalPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user.present?
  end
end
