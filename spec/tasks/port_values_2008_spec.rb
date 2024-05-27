# frozen_string_literal: true

require "rails_helper"
require "rake"

RSpec.describe "port_values_2008:import" do
  before do
    Rake.application.rake_require("tasks/port_values_2008")
    Rake::Task.define_task(:environment)
  end

  describe "import task" do
    let!(:task_name) { "port_values_2008:import" }
    let!(:file_content) { Rails.root.join("lib/data/port_values/2008_5_edition.json").read }

    context "when the rake task is a success" do
      it "finds or creates a cbhpm record" do
        expect(Cbhpm).to receive(:find_or_create_by).with(year: 2008, name: "5 edition").and_call_original

        Rake::Task[task_name].execute
      end

      it "outputs success message" do
        expect { Rake::Task[task_name].execute }.to output("Port values imported successfully\n").to_stdout
      end

      it "imports port values from JSON file and creates PortValues" do
        allow(File).to receive(:read).and_return(file_content)

        expect(JSON).to receive(:parse).with(file_content).and_call_original

        expect { Rake::Task[task_name].execute }.to change(PortValue, :count).by(42)
      end
    end

    context "when the rake task is a failure" do
      it "raises an error when it fails to read the JSON file" do
        allow(File).to receive(:read).and_raise(Errno::ENOENT)

        expect { Rake::Task[task_name].execute }.to raise_error(Errno::ENOENT)
      end

      it "raises an error when it fails to create a PortValue" do
        allow(PortValue).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)

        expect { Rake::Task[task_name].execute }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
