# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Default Procedures seed" do
  let(:seed_file) { Rails.root.join("db/seeds/02_procedures_default.rb") }

  before do
    Procedure.destroy_all
    PortValue.destroy_all
    CbhpmProcedure.destroy_all
    Cbhpm.destroy_all

    allow(Rake::Task).to receive(:clear)
    allow(Rails.application).to receive(:load_tasks)

    cbhpm = Cbhpm.create!(year: 2008, name: "5 edition")

    port_values_task = instance_double(Rake::Task)
    allow(port_values_task).to receive(:invoke) do
      if defined?(PortValue) && defined?(Cbhpm)
        %w[1A 2B 3C].each do |port_code|
          PortValue.create!(
            cbhpm_id: cbhpm.id,
            port: port_code,
            anesthetic_port: "0",
            amount_cents: rand(100..500)
          )
        end
      end
    end

    create_json_task = instance_double(Rake::Task)
    allow(create_json_task).to receive(:invoke)

    persist_task = instance_double(Rake::Task)
    allow(persist_task).to receive(:invoke) do |_file_path|
      if defined?(Procedure) && defined?(CbhpmProcedure) && cbhpm
        3.times do |i|
          procedure = Procedure.create!(
            code: "TEST#{i}",
            name: "Test Procedure #{i}",
            amount_cents: 1000,
            custom: false
          )

          CbhpmProcedure.create!(
            procedure: procedure,
            cbhpm: cbhpm,
            port: %w[2B 3A 2A][i % 3],
            anesthetic_port: "0"
          )
        end
      end
    end
    allow(persist_task).to receive(:reenable)

    allow(Rake::Task).to receive(:[]).with("port_values_2008:import").and_return(port_values_task)
    allow(Rake::Task).to receive(:[]).with("procedures:create_json_file").and_return(create_json_task)
    allow(Rake::Task).to receive(:[]).with("procedures:persist_in_database").and_return(persist_task)

    test_batch_file = Rails.root.join("lib/data/procedures/batch_1.json").to_s
    allow(Rails.root).to receive(:glob).with("lib/data/procedures/batch_*.json").and_return([test_batch_file])
    allow(File).to receive(:exist?).and_return(true)

    allow(Rails.logger).to receive(:debug)
  end

  it "runs without errors" do
    expect { load seed_file }.not_to raise_error
  end

  it "creates records in the database" do
    initial_procedure_count = Procedure.count
    initial_port_value_count = PortValue.count
    initial_cbhpm_procedure_count = CbhpmProcedure.count

    load seed_file

    expect(Procedure.count).to be > initial_procedure_count
    expect(PortValue.count).to be > initial_port_value_count
    expect(CbhpmProcedure.count).to be > initial_cbhpm_procedure_count
  end
end
