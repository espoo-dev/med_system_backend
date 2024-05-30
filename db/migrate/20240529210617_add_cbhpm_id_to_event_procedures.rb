# frozen_string_literal: true

class AddCbhpmIdToEventProcedures < ActiveRecord::Migration[7.0]
  def change
    add_column :event_procedures, :cbhpm_id, :integer, default: 1, null: false
    add_foreign_key :event_procedures, :cbhpms
    add_index :event_procedures, :cbhpm_id
  end
end
