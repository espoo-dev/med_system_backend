# frozen_string_literal: true

class MedicalShiftPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user.present?
  end
end
