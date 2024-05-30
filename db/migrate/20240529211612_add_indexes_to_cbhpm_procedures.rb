# frozen_string_literal: true

class AddIndexesToCbhpmProcedures < ActiveRecord::Migration[7.0]
  def change
    add_index :cbhpm_procedures, %i[procedure_id cbhpm_id]
  end
end
