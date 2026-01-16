# frozen_string_literal: true

module Api
  module V1
    class MedicalShiftsController < ApiController
      def hospital_name_suggestion_index
        authorize(MedicalShift)
        authorized_scope = policy_scope(MedicalShift)

        result = MedicalShifts::HospitalNameSuggestion.result(
          scope: authorized_scope
        )

        render json: {
          names: result.names
        }, status: :ok
      end

      def amount_suggestions_index
        authorize(MedicalShift)

        result = MedicalShifts::AmountSuggestion.result(
          scope: policy_scope(MedicalShift)
        )
        render json: { amounts_cents: result.amounts_cents }, status: :ok
      end

      def index
        authorize(MedicalShift)
        authorized_scope = policy_scope(MedicalShift)
        medical_shifts = MedicalShifts::List.result(
          scope: authorized_scope,
          params: params.permit(:page, :per_page, :month, :year, :paid, :hospital_name).to_h
        ).medical_shifts

        amount_cents = MedicalShifts::TotalAmountCents.call(medical_shifts: medical_shifts)

        render json: {
          total: amount_cents.total,
          total_paid: amount_cents.paid,
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
          deleted_successfully_render(result.medical_shift)
        else
          render json: result.error, status: :unprocessable_entity
        end
      end

      private

      def medical_shift
        @medical_shift ||= MedicalShifts::Find.result(
          id: params[:id],
          scope: policy_scope(MedicalShift)
        ).medical_shift
      end

      def medical_shift_params
        params.permit(:hospital_name, :workload, :start_date, :start_hour, :amount_cents, :paid, :color).to_h
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
