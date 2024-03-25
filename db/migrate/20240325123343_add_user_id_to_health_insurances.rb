# frozen_string_literal: true

class AddUserIdToHealthInsurances < ActiveRecord::Migration[7.0]
  def change
    add_column :health_insurances, :user_id, :integer
    add_index :health_insurances, :user_id
  end
end
