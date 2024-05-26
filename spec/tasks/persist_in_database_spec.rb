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
    let(:procedures_codes) { procedures.pluck(:code) }
    let(:procedures_names) { procedures.pluck(:name) }

    before(:each) { Rake::Task[task_name].reenable }

    it {
      expect do
        run_rake
      end.to output("Procedures added in database\n").to_stdout
    }

    it 'persists procedures in database' do
      run_rake

      expect(procedures.count).to eq(3)
      expect(procedures_codes).to eq(["1", "2", "3"])
      expect(procedures_names).to eq(["Teste 1", "Teste 2", "Teste 3"])
    end
  end

  context "when fail" do
    let(:path_file) { "spec/fixtures/batch_test_error.json" }

    before(:each) { Rake::Task[task_name].reenable }

    context 'when a row has error' do
      it 'raises error and rollback persisted data' do
        expect{ run_rake }.to raise_error(StandardError)
        expect(procedures.count).to eq(0)
      end
    end

    context 'when does not have path_file' do
      it 'raises error' do
        expect{ run_rake }.to raise_error(StandardError)
        expect(procedures.count).to eq(0)
      end
    end
  end
end
