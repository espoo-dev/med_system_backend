# frozen_string_literal: true

class ProcedurePolicy < ApplicationPolicy
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
