# frozen_string_literal: true

module Users
  class DestroySelf < Actor
    input :user, type: User
    input :password, type: String

    def call
      return fail!(error: "Wrong password", status: :unauthorized) unless valid_password?

      ActiveRecord::Base.transaction { user.destroy_fully! }

      true
    rescue StandardError => e
      fail!(error: e.message)
    end

    private

    def valid_password?
      user.valid_password?(password)
    end
  end
end
