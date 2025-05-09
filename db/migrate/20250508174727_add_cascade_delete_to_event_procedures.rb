# frozen_string_literal: true

class AddCascadeDeleteToEventProcedures < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :event_procedures, :patients

    add_foreign_key :event_procedures, :patients, on_delete: :cascade
  end
end
