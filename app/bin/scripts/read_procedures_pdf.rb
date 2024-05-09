# frozen_string_literal: true

require "csv"

module Scripts
  class ReadProceduresPDF
    attr_reader :path_file, :batch_size

    def initialize(path_file, batch_size)
      @path_file = path_file
      @batch_size = batch_size
    end

    def run
      csv_data_to_json
    end

    private

    def csv_data_to_json
      file.each_slice(batch_size).with_index do |batch, batch_index|
        procedures = { batch: { rows: [] } }

        batch.each_with_index do |row, index|
          from_row_to_json(procedures, row, index, batch_index)
        end

        batches_procedures_parsed(batch_index, procedures.to_json)
      end
    end

    def from_row_to_json(json, row, row_index, batch_index)
      return if row.first.blank?

      json.dig(:batch, :rows) << { code: row[0], name: row[1]&.gsub("'",""), port: row[4] }
      puts "Concluído - Batch: #{ batch_index + 1 } - linha: #{ row_index + 1 }"
    rescue StandardError => e
      logger.warn("ERRO: #{e.message} - Batch: #{batch_index}/linha: #{row_index + 1}|Backtrace: #{e.backtrace}")
      puts "ERRO - Confira no arquivo de log"
    end

    def batches_procedures_parsed(index, data)
      File.write("batch_#{index + 1}.json", data)
    end

    def file
      @file ||= CSV.open(path_file)
    end

    def logger
      @logger ||= Logger.new(Rails.root.join("log/populate_procedures_from_csv.log"))
    end
  end
end
