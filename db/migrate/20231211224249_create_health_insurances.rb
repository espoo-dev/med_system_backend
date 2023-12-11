# frozen_string_literal: true

class CreateHealthInsurances < ActiveRecord::Migration[7.0]
  def change
    create_table :health_insurances do |t|
      t.string :name

      t.timestamps
    end
  end
end
