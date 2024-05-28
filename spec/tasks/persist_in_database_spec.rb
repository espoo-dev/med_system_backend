# frozen_string_literal: true

require "rails_helper"
require "rake"
require_relative "../../lib/scripts/persist_procedures"

RSpec.describe "persist_in_database" do
  let(:task_name) { "procedures:persist_in_database" }
  let(:path_file) { "spec/fixtures/batch_test.json" }
  let(:run_rake) { Rake::Task[task_name].invoke(path_file) }
  let(:procedures) { Procedure.all }

  before do
    Rake.application.rake_require("tasks/persist_in_database")
    Rake::Task.define_task(:environment)
  end

  context "when successful" do
    let(:cbhpm) { create(:cbhpm, year: 2008, name: "5 edition") }
    let(:procedures_ids) { procedures.pluck(:id) }
    let(:procedures_codes) { procedures.pluck(:code) }
    let(:procedures_names) { procedures.pluck(:name) }
    let(:cbhpm_procedures) { CbhpmProcedure.where(procedure_id: procedures_ids) }

    before do
      cbhpm
      Rake::Task[task_name].reenable
    end

    it {
      expect do
        run_rake
      end.to output("Procedures added in database\n").to_stdout
    }

    context "when persists procedures in database" do
      before { run_rake }

      it { expect(procedures.count).to eq(3) }
      it { expect(procedures_codes).to eq(%w[1 2 3]) }
      it { expect(procedures_names).to eq(["Test 1", "Test 2", "Test 3"]) }
      it { expect(cbhpm_procedures.count).to eq(3) }
    end

    context "when already code exist in database" do
      let(:procedure_persisted) { create(:procedure, code: "1", name: "Already pesisted") }

      before { procedure_persisted }

      it "skips procedure code persisted" do
        run_rake

        expect(procedures.count).to eq(3)
        expect(procedures_names).to eq(["Already pesisted", "Test 2", "Test 3"])
        expect(cbhpm_procedures.count).to eq(2)
      end
    end
  end

  context "when fail" do
    before { Rake::Task[task_name].reenable }

    context "when a row has error" do
      let(:path_file) { "spec/fixtures/batch_test_error.json" }

      it "raises error and rollback persisted data" do
        expect { run_rake }.to raise_error(StandardError)
        expect(procedures.count).to eq(0)
      end
    end

    context "when anesthesic port is nil" do
      let(:path_file) { "spec/fixtures/batch_anesthetic_port_error.json" }
      let(:cbhpm) { create(:cbhpm, year: 2008, name: "5 edition") }

      before { cbhpm }

      it "raises error" do
        expect { run_rake }.to raise_error(StandardError, "Check if all attributes are presents!")
        expect(procedures.count).to eq(0)
      end
    end

    context "when cbhpm is nil" do
      let(:path_file) { "spec/fixtures/batch_anesthetic_port_error.json" }

      it "raises error" do
        expect { run_rake }.to raise_error(StandardError, "Cbhpm 5 edition(2008) not created")
        expect(procedures.count).to eq(0)
      end
    end
  end
end
