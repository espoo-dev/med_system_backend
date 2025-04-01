# frozen_string_literal: true

Rake::Task.clear
Rails.application.load_tasks

$stdout.puts "2. Creating default Procedures..."

Rake::Task["port_values_2008:import"].invoke
Rake::Task["procedures:create_json_file"].invoke("lib/data/procedures.csv", 100)

batch_files = Rails.root.glob("lib/data/procedures/batch_*.json")

if batch_files.empty?
  $stdout.puts "No JSON files found."
else
  batch_files.each do |batch_file|
    next unless File.exist?(batch_file)

    $stdout.puts "Importing #{batch_file}"

    Rake::Task["procedures:persist_in_database"].invoke(batch_file)
    Rake::Task["procedures:persist_in_database"].reenable
  end
end

$stdout.puts "Created default Procedures!"
