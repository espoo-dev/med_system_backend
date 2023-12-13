# frozen_string_literal: true

class ProcedurePolicy < ApplicationPolicy
  def index?
    user.present?
  end
end
