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

      def create
        authorize(MedicalShift)
        result = MedicalShifts::Create.result(attributes: medical_shift_params)

        if result.success?
          render json: result.medical_shift, status: :created
        else
          render json: result.medical_shift.errors, status: :unprocessable_entity
        end
      end

      private

      def medical_shift_params
        params.permit(:hospital_id, :workload, :date, :amount_cents, :was_paid).to_h
      end
    end
  end
end
