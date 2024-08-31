# frozen_string_literal: true

class PatientPolicy < ApplicationPolicy
  class Scope < CurrentUserScope
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
