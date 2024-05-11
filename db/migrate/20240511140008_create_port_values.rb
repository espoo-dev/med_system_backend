# frozen_string_literal: true

class CreatePortValues < ActiveRecord::Migration[7.0]
  def change
    create_table :port_values do |t|
      t.references :cbhpm, null: false, foreign_key: true
      t.string :port
      t.string :anesthetic_port
      t.decimal :amount_cents, precision: 10, scale: 2

      t.timestamps
    end
  end
end
