# frozen_string_literal: true

class AddDeletedAtToProcedures < ActiveRecord::Migration[7.1]
  def change
    add_column :procedures, :deleted_at, :datetime
    add_index :procedures, :deleted_at
  end
end
