# frozen_string_literal: true

module Api
  module V1
    class HealthInsurancesController < ApiController
      def index
        health_insurances = HealthInsurance.page(params[:page]).per(params[:per_page])
        authorize(health_insurances)

        render json: health_insurances, status: :ok
      end
    end
  end
end
