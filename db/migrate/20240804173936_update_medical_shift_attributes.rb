# frozen_string_literal: true

class UpdateMedicalShiftAttributes < ActiveRecord::Migration[7.1]
  def up
    remove_reference :medical_shifts, :hospital, index: true, foreign_key: true

    change_table :medical_shifts, bulk: true do |t|
      t.string :hospital_name, default: "", null: false
      t.time :start_hour, null: false
      t.rename :date, :start_date
      t.rename :was_paid, :payd
      t.change :start_date, :date
    end
  end

  def down
    add_reference :medical_shifts, :hospital, index: true, foreign_key: true

    change_table :medical_shifts, bulk: true do |t|
      t.rename :start_date, :date
      t.rename :payd, :was_paid
      t.change :date, :datetime
      t.remove :hospital_name
      t.remove :start_hour
    end
  end
end
