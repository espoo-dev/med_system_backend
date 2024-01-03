# frozen_string_literal: true

class HospitalPolicy < ApplicationPolicy
  def index?
    user.present?
  end
end
