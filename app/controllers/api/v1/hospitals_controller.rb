# frozen_string_literal: true

module Api
  module V1
    class HospitalsController < ApiController
      def index
        hospitals = Hospital.page(params[:page]).per(params[:per_page])
        authorize(hospitals)

        render json: hospitals, status: :ok
      end

      def create
        authorize(Hospital)
        result = Hospitals::Create.result(attributes: hospital_params)

        if result.success?
          render json: result.hospital, status: :created
        else
          render json: result.hospital.errors, status: :unprocessable_entity
        end
      end

      private

      def hospital_params
        params.permit(:name, :address).to_h
      end
    end
  end
end
