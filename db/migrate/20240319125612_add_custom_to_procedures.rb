# frozen_string_literal: true

class AddCustomToProcedures < ActiveRecord::Migration[7.0]
  def change
    add_column :procedures, :custom, :boolean, default: false, null: false
  end
end
