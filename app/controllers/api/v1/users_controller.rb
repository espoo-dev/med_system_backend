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

        unless current_user.valid_password?(params[:password])
          return render json: { error: "Wrong password" }, status: :unauthorized
        end

        if current_user.destroy
          render json: { message: "Account deleted successfully" }, status: :ok
        else
          render json: { error: "Unable to delete account" }, status: :unprocessable_entity
        end
      end

      private

      def page
        params[:page]
      end

      def per_page
        params[:per_page]
      end
    end
  end
end
