# frozen_string_literal: true

class ProcedurePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    is_user_owner?
  end

  def destroy?
    is_user_owner?
  end
end
