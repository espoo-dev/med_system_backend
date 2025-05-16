# frozen_string_literal: true

class AddDeletedAtToHospitals < ActiveRecord::Migration[7.1]
  def change
    add_column :hospitals, :deleted_at, :datetime
    add_index :hospitals, :deleted_at
  end
end
