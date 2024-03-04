# frozen_string_literal: true

class AddUniqueConstraintToProceduresCode < ActiveRecord::Migration[7.0]
  def change
    add_index :procedures, :code, unique: true
  end
end
