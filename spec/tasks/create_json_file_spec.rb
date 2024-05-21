# frozen_string_literal: true

require "rails_helper"
require "rake"
require_relative "../../lib/scripts/read_procedures_pdf"

RSpec.describe "create_json_file" do
  let(:task_name) { "procedures:create_json_file" }
  let(:file_path) { "spec/fixtures/procedures_test.csv" }
  let(:files_dir) { Dir.glob("lib/data/procedures/*") }
  let(:files_selected) { files_dir.select { |file| File.file?(file) } }

  before do
    Rake.application.rake_require("tasks/create_json_file")
    Rake::Task.define_task(:environment)
    Rake::Task[task_name].reenable
  end

  after(:context) do
    FileUtils.rm_rf(Dir["lib/data/procedures/*"])
  end

  context "when successful" do
    it {
      expect do
        Rake::Task[task_name].invoke(file_path, 1)
      end.to output("Procedures exported to json files\n").to_stdout
    }

    it { expect(files_selected.count).to eq(3) }

    it "JSON file must have JSON with keys" do
      files_selected.each do |path_file|
        file = JSON.load_file(path_file)

        expect(file.keys).to include("batch")
        expect(file["batch"].keys).to include("procedures")

        file.dig("batch", "procedures").each do |procedure|
          expect(procedure.keys).to include("code", "port", "name")
        end
      end
    end
  end

  context "when the rake task is a failure" do
    context "when code is not valid" do
      let(:file_path_code_error) { "spec/fixtures/procedures_code_error_test.csv" }

      it {
        expect do
          Rake::Task[task_name].invoke(file_path_code_error, 1)
        end.to raise_error(StandardError, "Code is not valid!")
      }
    end

    context "when port is not valid" do
      let(:file_path_port_error) { "spec/fixtures/procedures_port_error_test.csv" }

      it {
        expect do
          Rake::Task[task_name].invoke(file_path_port_error, 1)
        end.to raise_error(StandardError, "Port is not valid!")
      }
    end
  end
end
