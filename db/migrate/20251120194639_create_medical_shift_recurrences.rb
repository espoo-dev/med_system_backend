# frozen_string_literal: true

class CreateMedicalShiftRecurrences < ActiveRecord::Migration[7.1]
  def change # rubocop:disable Metrics/MethodLength
    create_table :medical_shift_recurrences do |t|
      t.references :user, null: false, foreign_key: true, index: true

      t.string :frequency, null: false
      t.integer :day_of_week
      t.integer :day_of_month
      t.date :start_date, null: false
      t.date :end_date

      t.string :workload, null: false
      t.time :start_hour, null: false
      t.string :hospital_name, null: false, default: ""
      t.integer :amount_cents, default: 0, null: false

      t.date :last_generated_until
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :medical_shift_recurrences, :deleted_at
    add_index :medical_shift_recurrences, :last_generated_until
    add_index :medical_shift_recurrences, %i[user_id deleted_at]
  end
end
