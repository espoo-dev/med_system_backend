# frozen_string_literal: true

class AddUserIdToProcedures < ActiveRecord::Migration[7.0]
  def change
    add_column :procedures, :user_id, :integer
    add_index :procedures, :user_id
  end
end
