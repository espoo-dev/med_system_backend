# frozen_string_literal: true

class AddConfirmableFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.timestamp :confirmed_at
      t.timestamp :confirmation_sent_at
      t.text :confirmation_token
      t.text :unconfirmed_email
    end
  end
end
