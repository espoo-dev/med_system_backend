# frozen_string_literal: true

class MedicalShiftPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      if user.present?
        scope.where(user:)
      else
        scope.none
      end
    end
  end

  def index?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    user.present? && record.user == user
  end
end
