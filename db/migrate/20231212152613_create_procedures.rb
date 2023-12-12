# frozen_string_literal: true

class CreateProcedures < ActiveRecord::Migration[7.0]
  def change
    create_table :procedures do |t|
      t.string :name, null: false
      t.string :code, null: false

      t.timestamps
    end
  end
end
