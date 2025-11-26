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
end
