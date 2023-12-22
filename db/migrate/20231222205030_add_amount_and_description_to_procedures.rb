# frozen_string_literal: true

class AddAmountAndDescriptionToProcedures < ActiveRecord::Migration[7.0]
  def change
    change_table :procedures, bulk: true do |t|
      t.integer :amount_cents, null: false, default: 0
      t.text :description
    end
  end
end
