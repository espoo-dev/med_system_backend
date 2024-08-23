# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def is_user_owner?
    user.present? && user == record.user
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class ApplicationScope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    protected

    attr_reader :user, :scope
  end

  class CurrentUserScope < ApplicationScope
    def resolve
      if user.present?
        scope.where(user:)
      else
        scope.none
      end
    end
  end
end
