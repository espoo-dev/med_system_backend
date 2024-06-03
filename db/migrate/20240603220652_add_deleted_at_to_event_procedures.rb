# frozen_string_literal: true

class AddDeletedAtToEventProcedures < ActiveRecord::Migration[7.0]
  def change
    add_column :event_procedures, :deleted_at, :datetime
    add_index :event_procedures, :deleted_at
  end
end
