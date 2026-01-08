# frozen_string_literal: true

module Api
  module V1
    class PatientsController < ApiController
      def index
        authorized_scope = policy_scope(Patient)
        patients = Patients::List.result(
          scope: authorized_scope,
          params: params.permit(:page, :per_page).to_h
        ).patients
          .includes([:event_procedures])

        authorize(patients)

        render json: patients, status: :ok
      end

      def create
        authorize(Patient)
        result = Patients::Create.result(attributes: patient_params)

        if result.success?
          render json: result.patient, status: :created
        else
          render json: result.patient.errors, status: :unprocessable_entity
        end
      end

      def update
        authorize(patient)
        result = Patients::Update.result(id: patient.id.to_s, attributes: patient_params)

        if result.success?
          render json: result.patient, status: :ok
        else
          render json: result.patient.errors, status: :unprocessable_entity
        end
      end

      def destroy
        authorize(patient)
        result = Patients::Destroy.result(id: patient.id.to_s)

        if result.success?
          deleted_successfully_render(result.patient)
        else
          render json: result.error, status: :unprocessable_entity
        end
      end

      private

      def patient
        @patient ||= Patients::Find.result(
          id: params[:id],
          scope: policy_scope(Patient)
        ).patient
      end

      def patient_params
        params.permit(:name).to_h.merge(user_id: current_user.id)
      end
    end
  end
end
