# frozen_string_literal: true

module Api
  module V1
    class ApiController < ActionController::API
      include Pundit::Authorization
      include Respondable

      after_action :verify_authorized

      before_action :authenticate_devise_api_token!
      before_action :set_paper_trail_whodunnit

      rescue_from Pundit::NotAuthorizedError, with: :render_unauthorized
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ServiceActor::ArgumentError, with: :render_bad_request

      def current_user
        current_devise_api_user
      end

      def render_unauthorized(message = "Unauthorized")
        render json: { error: message }, status: :unauthorized
      end

      def render_not_found(exception)
        render json: { error: exception.message }, status: :not_found
      end

      def render_bad_request(exception)
        render json: { error: exception.message }, status: :bad_request
      end
    end
  end
end
