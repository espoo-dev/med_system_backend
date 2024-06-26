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
      csv_data_to_json!
    end

    private

    def csv_data_to_json!
      file.each_slice(batch_size).with_index do |batch, batch_index|
        procedures_hash = { batch: { procedures: [] } }

        batch.each_with_index do |row, index|
          args = { procedures_hash: procedures_hash, row: row, index: index, batch_index: batch_index }

          begin
            validate_data_row!(row)
            from_row_to_json(args)
          rescue StandardError => e
            raise StandardError, e.message
          end
        end

        batches_procedures_parsed(batch_index, procedures_hash.to_json)
      end
    end

    def validate_data_row!(row)
      return if row.blank?

      validate_code!(row[0])
      validate_port!(row[4])
    end

    def validate_code!(code)
      return false if code.blank?

      regex_only_digits = /^\d+$/
      return true if regex_only_digits.match?(code)

      raise StandardError, "Code is not valid!"
    end

    def validate_port!(port)
      return false if port.blank?

      regex_digits_and_letter = /^\d+[a-zA-Z]$/
      return true if regex_digits_and_letter.match?(port)

      raise StandardError, "Port is not valid!"
    end

    def from_row_to_json(args)
      return if args[:row].first.blank?

      row = args[:row]

      args[:procedures_hash].dig(:batch, :procedures) << { code: row[0],
                                                           name: row[1],
                                                           port: row[4],
                                                           anesthetic_port: row[9] }
      puts_message("DONE - Batch: #{args[:batch_index] + 1} - row: #{args[:index] + 1}")
    end

    def batches_procedures_parsed(index, data)
      create_dir
      File.write("lib/data/procedures/batch_#{index + 1}.json", data)
    end

    def create_dir
      return false if Dir.glob("lib/data/*").include?("lib/data/procedures")

      Dir.mkdir("lib/data/procedures")
    end

    def file
      @file ||= CSV.open(path_file)
    end

    def puts_message(message)
      Rails.logger.debug(message)
    end
  end
end
