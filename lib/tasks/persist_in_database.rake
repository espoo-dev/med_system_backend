# frozen_string_literal: true

require_relative "../scripts/persist_procedures"

namespace :procedures do
  desc "Create procedures from json file"
  task :persist_in_database, %i[path_file] => :environment do |_task, args|
    path_file = args[:path_file]

    instance = Scripts::PopulateProcedures.new(path_file)
    instance.run!

    Rails.logger.warn "Procedures added in database"
  rescue StandardError => e
    raise StandardError, e.message
  end
end
