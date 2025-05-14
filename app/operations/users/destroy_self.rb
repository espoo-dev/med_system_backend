# frozen_string_literal: true

module Users
  class DestroySelf < Actor
    Result = Struct.new(:success?, :error)

    attr_reader :user, :password

    def initialize(user, password)
      @user = user
      @password = password
    end

    def call
      return Result.new(false, "Wrong password") unless valid_password?

      ActiveRecord::Base.transaction { user.destroy }

      Result.new(true, nil)
    rescue StandardError => e
      Result.new(false, e.message)
    end

    private

    def valid_password?
      user.valid_password?(password)
    end
  end
end
