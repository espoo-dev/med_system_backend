# frozen_string_literal: true

module Api
  module V1
    class MedicalShiftsController < ApiController
      def index
        medical_shifts = MedicalShifts::List.result(
          page: params[:page],
          per_page: params[:per_page],
          payd: params[:payd],
          month: params[:month],
          hospital_id: params[:hospital_id]
        ).medical_shifts
        authorize(medical_shifts)

        render json: medical_shifts, status: :ok
      end
    end
  end
end
