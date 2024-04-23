# frozen_string_literal: true

class AddUniqueIndexToHealthInsuarnces < ActiveRecord::Migration[7.0]
  def change
    add_index :health_insurances, %i[name user_id], unique: true
  end
end
