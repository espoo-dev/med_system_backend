# frozen_string_literal: true

class AddLockableToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.integer :failed_attempts
      t.string :unlock_token
      t.datetime :locked_at
    end
  end
end
