# frozen_string_literal: true

module Api
  module V1
    class ApiController < ActionController::API
      include Pundit::Authorization
      include Respondable

      after_action :verify_authorized

      before_action :authenticate_devise_api_token!
      before_action :set_paper_trail_whodunnit
      before_action :log_authenticated_request

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

      private

      # Tags aren't reliable for user_id here: Rails computes config.log_tags once,
      # in the Rack middleware, before authenticate_devise_api_token! runs.
      # Logging it explicitly keeps user_id and request_id on the same line.
      def log_authenticated_request
        Rails.logger.info("user_id=#{current_user&.id} request_id=#{request.request_id}")
      end

      # PaperTrail::Rails::Controller wires this into set_paper_trail_controller_info
      # automatically; the returned keys must match columns on the versions table.
      def info_for_paper_trail
        { source: "api_request", request_id: request.request_id }
      end
    end
  end
end
