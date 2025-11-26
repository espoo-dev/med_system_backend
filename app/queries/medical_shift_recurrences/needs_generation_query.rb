# frozen_string_literal: true

module MedicalShiftRecurrences
  class NeedsGenerationQuery < ApplicationQuery
    attr_reader :target_date, :relation

    def initialize(target_date:, relation: MedicalShiftRecurrence)
      @target_date = target_date
      @relation = relation
    end

    def call
      relation
        .active
        .where(
          "last_generated_until IS NULL OR last_generated_until < ?",
          target_date
        )
    end
  end
end
