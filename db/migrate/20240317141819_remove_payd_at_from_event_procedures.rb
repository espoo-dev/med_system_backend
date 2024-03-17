# frozen_string_literal: true

class RemovePaydAtFromEventProcedures < ActiveRecord::Migration[7.0]
  def change
    remove_column :event_procedures, :payd_at, :datetime
  end
end
