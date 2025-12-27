# frozen_string_literal: true

class AddColorToMedicalShiftsAndRecurrences < ActiveRecord::Migration[7.1]
  def change
    add_column :medical_shifts, :color, :string, default: "#ffffff", null: false
    add_column :medical_shift_recurrences, :color, :string, default: "#ffffff", null: false
  end
end
