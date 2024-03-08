# frozen_string_literal: true

module Api
  module V1
    class EventProceduresDashboardController < ApiController
      after_action :verify_authorized

      def amount_by_day
        authorize :amount_by_day, policy_class: EventProcedureDashboardPolicy

        result = EventProcedures::DashboardAmountByDay.result(amount_by_day_params)
        if result.success?
          render json: result.dashboard_data, status: :ok
        else
          render json: { errors: [result[:error]] }, status: :unprocessable_entity
        end
      end

      private

      def amount_by_day_params
        params.permit(:start_date, :end_date)
      end
    end
  end
end
