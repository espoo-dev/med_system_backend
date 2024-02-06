# frozen_string_literal: true

class AddUserIdToEventProcedures < ActiveRecord::Migration[7.0]
  def change
    add_reference :event_procedures, :user, null: false, foreign_key: true, index: true # rubocop:disable Rails/NotNullColumn
  end
end
