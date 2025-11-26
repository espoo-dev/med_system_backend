# frozen_string_literal: true

class MedicalShiftRecurrencePolicy < ApplicationPolicy
  class Scope < CurrentUserScope
  end

  def index?
    user.present?
  end

  def create?
    user.present?
  end

  def destroy?
    user_owner?
  end
end
