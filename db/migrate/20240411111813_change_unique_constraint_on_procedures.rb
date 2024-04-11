# frozen_string_literal: true

class ChangeUniqueConstraintOnProcedures < ActiveRecord::Migration[7.0]
  def change
    remove_index :procedures, :code
    add_index :procedures, :code, unique: true, where: "(custom = false)"
  end
end
