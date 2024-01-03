# frozen_string_literal: true

module Api
  module V1
    class HospitalsController < ApiController
      def index
        hospitals = Hospital.page(params[:page]).per(params[:per_page])
        authorize(hospitals)

        render json: hospitals, status: :ok
      end
    end
  end
end
