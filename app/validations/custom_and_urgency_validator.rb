# frozen_string_literal: true

class CustomAndUrgencyValidator < ActiveModel::Validator
  def validate(record)
    return unless record.procedure&.custom && record.urgency

    record.errors.add(:base, "EventProcedure cannot have both custom and urgency as true")
  end
end
