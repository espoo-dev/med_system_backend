# frozen_string_literal: true

module EventProcedures
  class BuildTotalAmountCents < Actor
    input :event_procedure, type: EventProcedure

    output :total_amount_cents, type: Integer

    APARTMENT_PERCENTAGE = 1
    URGENCY_PERCENTAGE = 0.3
    ANESTHETIC_PORT_ZERO_AMOUNT = "3"

    def call
      self.total_amount_cents = base_amount_cents + apartment_amount + urgency_amount.to_i
    end

    private

    def base_amount_cents
      return event_procedure.procedure.amount_cents.to_i if event_procedure.procedure.custom?

      cbhpm_procedure = find_cbhpm_procedure
      return 0 unless cbhpm_procedure

      port_value = find_port_value(cbhpm_procedure)
      return value_for_anesthetic_port_zero(event_procedure) unless port_value

      port_value.amount_cents.to_i
    end

    def value_for_anesthetic_port_zero(event_procedure)
      port = PortValue.find_by(cbhpm_id: event_procedure.cbhpm_id, anesthetic_port: ANESTHETIC_PORT_ZERO_AMOUNT)
      port&.amount_cents.to_i 
    end

    def find_cbhpm_procedure
      CbhpmProcedure.find_by(
        procedure_id: event_procedure.procedure_id,
        cbhpm_id: event_procedure.cbhpm_id
      )
    end

    def find_port_value(cbhpm_procedure)
      PortValue.find_by(
        cbhpm_id: cbhpm_procedure.cbhpm_id,
        anesthetic_port: cbhpm_procedure.anesthetic_port
      )
    end

    def apartment_amount
      return 0 unless event_procedure.apartment?

      base_amount_cents * APARTMENT_PERCENTAGE
    end

    def urgency_amount
      return 0 unless event_procedure.urgency?

      base_amount_cents * URGENCY_PERCENTAGE
    end
  end
end
