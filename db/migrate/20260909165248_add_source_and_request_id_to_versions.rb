# frozen_string_literal: true

class AddSourceAndRequestIdToVersions < ActiveRecord::Migration[7.1]
  def change
    change_table :versions, bulk: true do |t|
      t.string :source
      t.string :request_id
      t.index :request_id
    end
  end
end
