# frozen_string_literal: true

class AddTotalAmountCentsToEventProcedures < ActiveRecord::Migration[7.0]
  def change
    add_column :event_procedures, :total_amount_cents, :integer
  end
end
