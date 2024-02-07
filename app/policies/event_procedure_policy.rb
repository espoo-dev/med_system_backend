# frozen_string_literal: true

class EventProcedurePolicy < ApplicationPolicy
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
    user.present? && owner?
  end

  def destroy?
    update?
  end
end
