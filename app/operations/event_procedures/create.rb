# frozen_string_literal: true

module EventProcedures
  class Create < Actor
    input :attributes, type: Hash
    input :user_id, type: Integer

    output :event_procedure, type: EventProcedure

    def call
      ActiveRecord::Base.transaction do
        create_event_procedure
        assign_total_amount_cents(event_procedure)
      end
      log_success
    end

    private

    def assign_total_amount_cents(event_procedure)
      build_total_amount = EventProcedures::BuildTotalAmountCents.result(event_procedure: event_procedure)
      event_procedure.total_amount_cents = build_total_amount.total_amount_cents
      event_procedure.save
    end

    def create_event_procedure
      self.event_procedure = EventProcedure.new(event_procedure_attributes)

      unless event_procedure.save
        log_error("EventProcedure", event_procedure.errors.full_messages)
        fail!(error: event_procedure.errors)
      end

      event_procedure
    end

    def event_procedure_attributes
      patient = find_or_create_patient
      procedure = find_or_create_procedure
      health_insurance = find_or_create_health_insurance

      validate_procedure(procedure)
      validate_health_insurance(health_insurance)

      merge_attributes(patient, procedure, health_insurance)
    end

    def validate_procedure(procedure)
      return unless procedure.errors.any?

      log_error("Procedure", procedure.errors.full_messages)
      fail!(error: procedure.errors)
    end

    def validate_health_insurance(health_insurance)
      return unless health_insurance.errors.any?

      log_error("HealthInsurance", health_insurance.errors.full_messages)
      fail!(error: health_insurance.errors)
    end

    def merge_attributes(patient, procedure, health_insurance)
      attributes
        .except(
          :patient_attributes,
          :procedure_attributes,
          :health_insurance_attributes
        ).merge(
          user_id: user_id,
          patient_id: patient.id,
          procedure_id: procedure.id,
          health_insurance_id: health_insurance.id
        )
    end

    def find_or_create_health_insurance
      HealthInsurances::FindOrCreate.result(params: attributes[:health_insurance_attributes]).health_insurance
    end

    def find_or_create_patient
      Patients::FindOrCreate.result(params: attributes[:patient_attributes]).patient
    end

    def find_or_create_procedure
      Procedures::FindOrCreate.result(params: attributes[:procedure_attributes]).procedure
    end

    def log_success
      Rails.logger.info(
        ">>> EventProcedure created successfully. ID: #{event_procedure.id}, User ID: #{user_id}"
      )
    end

    def log_error(model_name, errors)
      Rails.logger.error(
        ">>> Failed to create EventProcedure. User ID: #{user_id}, " \
        "#{model_name} Errors: #{errors.join(', ')}"
      )
    end
  end
end
