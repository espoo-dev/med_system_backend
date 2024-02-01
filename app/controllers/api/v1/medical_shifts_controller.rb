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
        amount_cents = MedicalShifts::TotalAmountCents.call

        render json: {
          total: amount_cents.total,
          total_payd: amount_cents.payd,
          total_unpaid: amount_cents.unpaid,
          medical_shifts: serialized_medical_shifts(medical_shifts)
        }, status: :ok
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

      def serialized_medical_shifts(medical_shifts)
        ActiveModelSerializers::SerializableResource.new(
          medical_shifts,
          each_serializer: MedicalShiftSerializer
        )
      end
    end
  end
end
