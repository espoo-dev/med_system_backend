# frozen_string_literal: true

Rake::Task.clear
Rails.application.load_tasks

Rails.logger.debug "2. Creating default Procedures..."

Rake::Task["port_values_2008:import"].invoke
Rake::Task["procedures:create_json_file"].invoke("lib/data/procedures.csv", 100)

batch_files = Rails.root.glob("lib/data/procedures/batch_*.json")

batch_files.each do |batch_file|
  next unless File.exist?(batch_file)

  Rails.logger.debug { "Importing #{batch_file}" }

  Rake::Task["procedures:persist_in_database"].invoke(batch_file)
  Rake::Task["procedures:persist_in_database"].reenable
end

Rails.logger.debug { "Created #{batch_files.count} default Procedures!" }
