# frozen_string_literal: true

class MedicalShiftPolicy < ApplicationPolicy
  class Scope < CurrentUserScope
  end

  def hospital_name_suggestion_index?
    user.present?
  end

  def index?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    user_owner?
  end

  def destroy?
    user_owner?
  end
end
