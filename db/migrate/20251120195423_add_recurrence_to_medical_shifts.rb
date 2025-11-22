# frozen_string_literal: true

class AddRecurrenceToMedicalShifts < ActiveRecord::Migration[7.1]
  def change
    add_reference :medical_shifts, :medical_shift_recurrence, foreign_key: true, null: true, index: true
  end
end
