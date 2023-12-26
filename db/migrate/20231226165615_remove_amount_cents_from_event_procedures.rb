# frozen_string_literal: true

class RemoveAmountCentsFromEventProcedures < ActiveRecord::Migration[7.0]
  def change
    remove_column :event_procedures, :amount_cents, :integer
  end
end
