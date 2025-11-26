# frozen_string_literal: true

module Api
  module V1
    class MedicalShiftRecurrencesController < ApiController
      after_action :verify_authorized, except: :index
      after_action :verify_policy_scoped, only: :index

      def index
        authorized_scope = policy_scope(MedicalShiftRecurrence)
        recurrences = authorized_scope
          .where(deleted_at: nil)
          .order(created_at: :desc)

        render json: recurrences, each_serializer: MedicalShiftRecurrenceSerializer
      end

      def create
        authorize(MedicalShiftRecurrence)
        result = MedicalShiftRecurrences::Create.result(
          attributes: recurrence_params,
          user_id: current_user.id
        )

        if result.success?
          render json: {
            medical_shift_recurrence: result.medical_shift_recurrence,
            shifts_generated: result.shifts_created.count
          }, status: :created
        else
          render json: { errors: result.error }, status: :unprocessable_content
        end
      end

      private

      def recurrence_params
        params.require(:medical_shift_recurrence).permit(
          :frequency,
          :day_of_week,
          :day_of_month,
          :start_date,
          :end_date,
          :workload,
          :start_hour,
          :hospital_name,
          :amount_cents
        ).to_h
      end
    end
  end
end
