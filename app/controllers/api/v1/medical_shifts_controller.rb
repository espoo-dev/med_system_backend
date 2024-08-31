# frozen_string_literal: true

module Api
  module V1
    class MedicalShiftsController < ApiController
      after_action :verify_authorized, except: :index
      after_action :verify_policy_scoped, only: :index

      def index
        authorized_scope = policy_scope(MedicalShift)
        medical_shifts = MedicalShifts::List.result(
          scope: authorized_scope,
          params: params.permit(:page, :per_page, :month, :year, :payd, :hospital_name).to_h
        ).medical_shifts

        amount_cents = MedicalShifts::TotalAmountCents.call(user_id: current_user.id)

        render json: {
          total: amount_cents.total,
          total_payd: amount_cents.payd,
          total_unpaid: amount_cents.unpaid,
          medical_shifts: serialized_medical_shifts(medical_shifts)
        }, status: :ok
      end

      def create
        authorize(MedicalShift)
        result = MedicalShifts::Create.result(attributes: medical_shift_params, user_id: current_user.id)

        if result.success?
          render json: result.medical_shift, status: :created
        else
          render json: result.medical_shift.errors, status: :unprocessable_entity
        end
      end

      def update
        authorize(medical_shift)
        result = MedicalShifts::Update.result(id: params[:id], attributes: medical_shift_params)

        if result.success?
          render json: result.medical_shift, status: :ok
        else
          render json: result.medical_shift.errors, status: :unprocessable_entity
        end
      end

      def destroy
        authorize(medical_shift)

        result = MedicalShifts::Destroy.result(id: medical_shift.id.to_s)

        if result.success?
          render json: { message: "MedicalShift deleted successfully." }, status: :ok
        else
          render json: result.error, status: :unprocessable_entity
        end
      end

      private

      def medical_shift
        @medical_shift ||= MedicalShifts::Find.result(id: params[:id]).medical_shift
      end

      def medical_shift_params
        params.permit(:hospital_name, :workload, :start_date, :start_hour, :amount_cents, :payd).to_h
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
