# frozen_string_literal: true

class AddDeletedAtToMedicalShifts < ActiveRecord::Migration[7.1]
  def change
    add_column :medical_shifts, :deleted_at, :datetime
    add_index :medical_shifts, :deleted_at
  end
end
