# frozen_string_literal: true

class CorrectPaydToPaid < ActiveRecord::Migration[7.1]
  def up
    rename_column :event_procedures, :payd, :paid

    rename_column :medical_shifts, :payd, :paid

    return unless index_exists?(:medical_shifts, :paid, name: "index_medical_shifts_on_payd")

    remove_index :medical_shifts, name: "index_medical_shifts_on_payd"
    add_index :medical_shifts, :paid, name: "index_medical_shifts_on_paid"
  end

  def down
    if index_exists?(:medical_shifts, :paid, name: "index_medical_shifts_on_paid")
      remove_index :medical_shifts, name: "index_medical_shifts_on_paid"
      add_index :medical_shifts, :payd, name: "index_medical_shifts_on_payd"
    end

    rename_column :medical_shifts, :paid, :payd
    rename_column :event_procedures, :paid, :payd
  end
end
