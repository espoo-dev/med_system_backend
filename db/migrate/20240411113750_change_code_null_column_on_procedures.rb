# frozen_string_literal: true

class ChangeCodeNullColumnOnProcedures < ActiveRecord::Migration[7.0]
  def change
    change_column_null :procedures, :code, true
  end
end
