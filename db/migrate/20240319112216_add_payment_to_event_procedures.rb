# frozen_string_literal: true

class AddPaymentToEventProcedures < ActiveRecord::Migration[7.0]
  def change
    add_column :event_procedures, :payment, :string, null: false, default: "health_insurance"
  end
end
