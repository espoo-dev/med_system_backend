# frozen_string_literal: true

class MedicalShiftPolicy < ApplicationPolicy
  class Scope < CurrentUserScope
  end

  def index?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    user.present? && owner?
  end

  def destroy?
    update?
  end
end
