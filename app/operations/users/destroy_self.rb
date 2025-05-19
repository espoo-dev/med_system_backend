# frozen_string_literal: true

module Users
  class DestroySelf < Actor
    input :user, type: User
    input :password, type: String

    def call
      fail!(error: "Wrong password") unless valid_password?

      ActiveRecord::Base.transaction { user.destroy_fully! }
    end

    private

    def valid_password?
      user.valid_password?(password)
    end
  end
end
