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
        batch.each_with_index do |row, index|
          from_row_to_json(row, index, batch_index)
        end

        batches_procedures_parsed(batch_index, procedures_hash.to_json)
      end
    end

    def from_row_to_json(row, row_index, batch_index)
      return if row.first.blank?

      procedures_hash.dig(:batch, :procedures) << { code: row[0], name: row[1], port: row[4] }
      puts_message("DONE - Batch: #{batch_index + 1} - row: #{row_index + 1}")
    rescue StandardError => e
      log_error(e, row_index, batch_index)
    end

    def log_error(error, row_index, batch_index)
      logger.warn("ERROR: #{error.message} - Batch: #{batch_index}/:row #{row_index + 1}|Backtrace: #{e.backtrace}")
      puts_message("ERROR - Check log file")
    end

    def batches_procedures_parsed(index, data)
      File.write("batch_#{index + 1}.json", data)
    end

    def procedures_hash
      @procedures_hash ||= { batch: { procedures: [] } }
    end

    def file
      @file ||= CSV.open(path_file)
    end

    def puts_message(message)
      Rails.logger.debug(message)
    end

    def logger
      @logger ||= Logger.new(Rails.root.join("log/populate_procedures_from_csv.log"))
    end
  end
end
