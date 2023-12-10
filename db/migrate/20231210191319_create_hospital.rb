# frozen_string_literal: true

class CreateHospital < ActiveRecord::Migration[7.0]
  def change
    create_table :hospitals do |t|
      t.string :name, index: { unique: true }, null: false
      t.string :address, index: { unique: true }, null: false

      t.timestamps
    end
  end
end
