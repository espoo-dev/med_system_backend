# frozen_string_literal: true

class AddDeletedAtToHealthInsurances < ActiveRecord::Migration[7.1]
  def change
    add_column :health_insurances, :deleted_at, :datetime
    add_index :health_insurances, :deleted_at
  end
end
