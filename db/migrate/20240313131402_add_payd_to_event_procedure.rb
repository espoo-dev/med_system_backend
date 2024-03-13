# frozen_string_literal: true

class AddPaydToEventProcedure < ActiveRecord::Migration[7.0]
  def change
    add_column :event_procedures, :payd, :boolean, null: false, default: false
  end
end
