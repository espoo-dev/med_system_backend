# frozen_string_literal: true

class AddDeletedAtToPatients < ActiveRecord::Migration[7.1]
  def change
    add_column :patients, :deleted_at, :datetime
    add_index :patients, :deleted_at
  end
end
