# frozen_string_literal: true

require_relative "../scripts/persist_procedures"

namespace :procedures do
  desc "Create procedures from json file"
  task :persist_in_database, %i[name_file] => :environment do |_task, args|
    name_file = args[:name_file]

    instance = Scripts::PopulateProcedures.new(name_file)
    instance.run!

    puts "Procedures added in database"
  rescue StandardError => e
    raise StandardError, e.message
  end
end
