# frozen_string_literal: true

class CreateCbhpms < ActiveRecord::Migration[7.0]
  def change
    create_table :cbhpms do |t|
      t.integer :year, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
