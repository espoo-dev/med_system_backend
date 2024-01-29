# frozen_string_literal: true

class CreateMedicalShifts < ActiveRecord::Migration[7.0]
  def change
    create_table :medical_shifts do |t|
      t.references :hospital, null: false, foreign_key: true
      t.string :workload, null: false
      t.datetime :date, null: false
      t.integer :amount_cents, default: 0, null: false
      t.boolean :was_paid, default: false, null: false

      t.timestamps
    end

    add_index :medical_shifts, :date
    add_index :medical_shifts, :was_paid
  end
end
