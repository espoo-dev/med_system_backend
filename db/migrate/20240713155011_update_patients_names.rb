# frozen_string_literal: true

class UpdatePatientsNames < ActiveRecord::Migration[7.0]
  def change
    patients = Patient.all

    patients.each do |patient|
      next if patient.update!(name: patient.name)

      fail_message = "Patient ID: #{patient.id} was not updated!"

      Rails.logger.debug(fail_message)
    end; nil
  end
end
