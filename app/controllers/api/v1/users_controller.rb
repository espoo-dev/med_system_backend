# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      def index
        users = User.page(page).per(per_page)

        authorize(users)

        render json: users, status: :ok
      end

      def destroy_self
        authorize current_user, :destroy_self?

        result = Users::DestroySelf.result(user: current_user, password: confirmation_password)

        if result.success?
          render json: { message: "Account deleted successfully" }, status: :ok
        else
          render json: { error: "Unable to delete account. Error: #{result.error}" }, status: :unprocessable_entity
        end
      end

      private

      def page
        params[:page]
      end

      def per_page
        params[:per_page]
      end

      def confirmation_password
        params[:password]
      end
    end
  end
end
