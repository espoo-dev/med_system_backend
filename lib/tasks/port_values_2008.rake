# frozen_string_literal: true

namespace :port_values_2008 do
  desc "Import port values from cbhpm 2008 5 edition"
  task import: :environment do
    file_path = Rails.root.join("lib/data/port_values/2008_5_edition.json")
    port_values = JSON.parse(File.read(file_path))

    port_values.each do |port_value|
      PortValue.create!(
        cbhpm_id: port_value["cbhpm_id"],
        port: port_value["port"],
        anesthetic_port: port_value["anesthetic_port"],
        amount_cents: port_value["amount_cents"]
      )
    end

    puts "Port values imported successfully"
  end
end
