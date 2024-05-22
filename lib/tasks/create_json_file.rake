# frozen_string_literal: true

require_relative "../scripts/read_procedures_pdf"

namespace :procedures do
  desc "It creates a json file with procedures to persist on database"
  task :create_json_file, %i[path_file limit] => :environment do |_task, args|
    path_file = args[:path_file]
    limit = args[:limit]

    instance = Scripts::ReadProceduresPDF.new(path_file, limit)
    instance.run

    puts "Procedures exported to json files"
  rescue StandardError => e
    raise StandardError, e.message
  end
end
