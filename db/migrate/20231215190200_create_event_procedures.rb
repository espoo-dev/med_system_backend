# frozen_string_literal: true

class CreateEventProcedures < ActiveRecord::Migration[7.0]
  def change # rubocop:disable Metrics/MethodLength
    create_table :event_procedures do |t|
      t.references :procedure, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.references :hospital, null: false, foreign_key: true
      t.references :health_insurance, null: false, foreign_key: true
      t.string :patient_service_number, null: false, unique: true
      t.datetime :date, null: false
      t.boolean :urgency, null: false, default: false
      t.integer :amount_cents, null: false, default: 0
      t.datetime :payd_at
      t.string :room_type, null: false

      t.timestamps
    end
  end
end
