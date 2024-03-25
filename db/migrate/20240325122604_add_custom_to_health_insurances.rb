# frozen_string_literal: true

class AddCustomToHealthInsurances < ActiveRecord::Migration[7.0]
  def change
    add_column :health_insurances, :custom, :boolean, default: false, null: false
  end
end
