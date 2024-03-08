# frozen_string_literal: true

class EventProcedureDashboardPolicy < ApplicationPolicy
  def amount_by_day?
    user.admin?
  end
end
