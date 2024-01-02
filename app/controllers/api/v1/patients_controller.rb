# frozen_string_literal: true

module Api
  module V1
    class PatientsController < ApiController
      def index
        patients = Patient.page(params[:page]).per(params[:per_page])

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
          render json: result.patient, status: :ok
        else
          render json: result.patient.errors, status: :unprocessable_entity
        end
      end

      private

      def patient
        @patient ||= Patients::Find.result(id: params[:id]).patient
      end

      def patient_params
        params.permit(:name).to_h
      end
    end
  end
end
