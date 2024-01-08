# frozen_string_literal: true

module Api
  module V1
    class HealthInsurancesController < ApiController
      def index
        health_insurances = HealthInsurance.page(params[:page]).per(params[:per_page])
        authorize(health_insurances)

        render json: health_insurances, status: :ok
      end

      def create
        authorize(HealthInsurance)
        result = HealthInsurances::Create.result(attributes: health_insurance_params)

        if result.success?
          render json: result.health_insurance, status: :created
        else
          render json: result.health_insurance.errors, status: :unprocessable_entity
        end
      end

      private

      def health_insurance_params
        params.permit(:name).to_h
      end
    end
  end
end
