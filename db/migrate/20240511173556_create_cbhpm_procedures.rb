# frozen_string_literal: true

class CreateCbhpmProcedures < ActiveRecord::Migration[7.0]
  def change
    create_table :cbhpm_procedures do |t|
      t.references :cbhpm, null: false, foreign_key: true
      t.references :procedure, null: false, foreign_key: true
      t.string :port, null: false
      t.string :anesthetic_port, null: false

      t.timestamps
    end
  end
end
