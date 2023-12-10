# frozen_string_literal: true

class CreateHospital < ActiveRecord::Migration[7.0]
  def change
    create_table :hospitals do |t|
      t.string :name, index: { unique: true }
      t.string :address, index: { unique: true }

      t.timestamps
    end
  end
end
