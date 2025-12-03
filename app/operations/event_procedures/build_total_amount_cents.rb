# frozen_string_literal: true

module EventProcedures
  class BuildTotalAmountCents < Actor
    input :event_procedure, type: EventProcedure

    output :total_amount_cents, type: Integer

    URGENCY_PERCENTAGE = 0.3
    ANESTHETIC_PORT_ZERO_AMOUNT = "3"
    APARTMENT_FACTOR = 2
    STANDARD_FACTOR = 1

    def call
      self.total_amount_cents = (base_amount_cents + urgency_amount.to_i) * apartment_multiplier
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
      port = event_procedure.cbhpm.port_values.find do |pv|
        pv.anesthetic_port == ANESTHETIC_PORT_ZERO_AMOUNT
      end
      port&.amount_cents.to_i
    end

    def find_cbhpm_procedure
      event_procedure.procedure.cbhpm_procedures.find do |cp|
        cp.cbhpm_id == event_procedure.cbhpm_id
      end
    end

    def find_port_value(cbhpm_procedure)
      event_procedure.cbhpm.port_values.find do |pv|
        pv.anesthetic_port == cbhpm_procedure.anesthetic_port
      end
    end

    def apartment_multiplier
      event_procedure.apartment? ? APARTMENT_FACTOR : STANDARD_FACTOR
    end

    def urgency_amount
      return 0 unless event_procedure.urgency?

      base_amount_cents * URGENCY_PERCENTAGE
    end
  end
end
