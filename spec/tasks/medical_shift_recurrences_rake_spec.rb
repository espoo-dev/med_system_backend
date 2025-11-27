# frozen_string_literal: true

require "rails_helper"
require "rake"

RSpec.describe "medical_shift_recurrences:generate_pending", type: :task do
  let(:user) { create(:user) }

  before do
    Rake.application.rake_require("tasks/medical_shift_recurrences")
    Rake::Task.define_task(:environment)
    Rake::Task["medical_shift_recurrences:generate_pending"].reenable
    Rake::Task["medical_shift_recurrences:generate_pending"].invoke
  end

  describe "execution" do
    context "with no recurrences" do
      it "executes without errors" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .not_to raise_error
      end

      it "outputs zero processed" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .to output(/Processed: 0 recurrences/).to_stdout
      end

      it "outputs zero shifts created" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .to output(/Shifts created: 0/).to_stdout
      end

      it "outputs no errors" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .to output(/No errors encountered/).to_stdout
      end
    end

    context "with recurrences needing generation" do
      let!(:recurrence_without_generation) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 1,
          start_date: Time.zone.tomorrow,
          last_generated_until: nil
        )
      end

      let!(:recurrence_with_old_generation) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "biweekly",
          day_of_week: 3,
          start_date: Time.zone.tomorrow,
          last_generated_until: 1.month.from_now.to_date
        )
      end

      it "executes without errors" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .not_to raise_error
      end

      it "generates shifts for recurrences" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .to change(MedicalShift, :count).by_at_least(10)
      end

      it "outputs number of recurrences processed" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .to output(/Processed: 2 recurrences/).to_stdout
      end

      it "outputs number of shifts created" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .to output(/Shifts created: \d+/).to_stdout
      end

      it "outputs found recurrences information" do
        output = capture_stdout do
          run_rake_task("medical_shift_recurrences:generate_pending")
        end

        expect(output).to include("Found 2 recurrences needing generation")
        expect(output).to include("ID: #{recurrence_without_generation.id}")
        expect(output).to include("ID: #{recurrence_with_old_generation.id}")
      end

      it "outputs completion message" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .to output(/Generation completed successfully/).to_stdout
      end

      it "outputs duration" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .to output(/in \d+\.\d+ seconds/).to_stdout
      end
    end

    context "with up-to-date recurrences" do
      before do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 5,
          start_date: Date.tomorrow,
          last_generated_until: 6.months.from_now.to_date
        )
      end

      it "does not process up-to-date recurrences" do
        output = capture_stdout do
          run_rake_task("medical_shift_recurrences:generate_pending")
        end

        expect(output).to include("Found 0 recurrences needing generation")
      end

      it "does not create new shifts" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .not_to change(MedicalShift, :count)
      end
    end

    context "with deleted recurrences" do
      before do
        create(
          :medical_shift_recurrence, :deleted,
          user: user,
          frequency: "weekly",
          day_of_week: 2,
          start_date: Date.tomorrow,
          last_generated_until: nil
        )
      end

      it "does not process deleted recurrences" do
        output = capture_stdout do
          run_rake_task("medical_shift_recurrences:generate_pending")
        end

        expect(output).to include("Found 0 recurrences needing generation")
      end
    end

    context "when errors occur" do
      let!(:recurrence) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 1,
          start_date: Date.tomorrow,
          last_generated_until: nil
        )
      end

      before do
        allow(MedicalShifts::Create).to receive(:call)
          .and_raise(StandardError.new("Database error"))
      end

      it "outputs error information" do
        output = capture_stdout do
          run_rake_task("medical_shift_recurrences:generate_pending")
        end

        expect(output).to include("ERRORS ENCOUNTERED")
        expect(output).to include("Recurrence ID: #{recurrence.id}")
        expect(output).to include("Database error")
      end

      it "outputs recurrence details for errors" do
        output = capture_stdout do
          run_rake_task("medical_shift_recurrences:generate_pending")
        end

        expect(output).to include("User ID: #{recurrence.user_id}")
        expect(output).to include("Frequency: #{recurrence.frequency}")
        expect(output).to include("Hospital: #{recurrence.hospital_name}")
      end

      it "still completes successfully" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .to output(/Generation completed successfully/).to_stdout
      end
    end

    context "when fatal error occurs" do
      before do
        allow(MedicalShiftRecurrences::GeneratePending).to receive(:result)
          .and_raise(StandardError.new("Fatal database error"))
      end

      it "outputs fatal error message" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .to output(/FATAL ERROR/).to_stdout
          .and raise_error(StandardError, "Fatal database error")
      end

      it "outputs backtrace" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .to output(/Backtrace:/).to_stdout
          .and raise_error(StandardError)
      end
    end

    context "with output formatting" do
      before do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 1,
          start_date: Date.tomorrow,
          last_generated_until: nil
        )
      end

      it "outputs dividers" do
        output = capture_stdout do
          run_rake_task("medical_shift_recurrences:generate_pending")
        end

        expect(output).to include("=" * 80)
        expect(output).to include("-" * 80)
      end

      it "outputs starting message" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .to output(/Starting generation of pending medical shift recurrences/).to_stdout
      end

      it "outputs results section" do
        expect { run_rake_task("medical_shift_recurrences:generate_pending") }
          .to output(/RESULTS:/).to_stdout
      end
    end

    context "with sample shifts output" do
      before do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 1,
          start_date: Date.tomorrow,
          last_generated_until: nil
        )
      end

      it "outputs sample of created shifts" do
        output = capture_stdout do
          run_rake_task("medical_shift_recurrences:generate_pending")
        end

        expect(output).to include("Sample of created shifts")
      end

      it "shows shift details in sample" do
        output = capture_stdout do
          run_rake_task("medical_shift_recurrences:generate_pending")
        end

        expect(output).to match(/ID: \d+ \| Date:/)
        expect(output).to match(/Hospital:/)
        expect(output).to match(/Recurrence ID:/)
      end
    end
  end

  describe "logging" do
    let!(:recurrence) do
      create(
        :medical_shift_recurrence,
        user: user,
        frequency: "weekly",
        day_of_week: 1,
        start_date: Date.tomorrow,
        last_generated_until: nil
      )
    end

    it "includes key information in output" do # rubocop:disable RSpec/MultipleExpectations
      output = capture_stdout do
        run_rake_task("medical_shift_recurrences:generate_pending")
      end

      expect(output).to include("Starting generation")
      expect(output).to include("Processed:")
      expect(output).to include("Shifts created:")
      expect(output).to include("Generation completed successfully")
    end

    it "includes duration in output" do
      output = capture_stdout do
        run_rake_task("medical_shift_recurrences:generate_pending")
      end

      expect(output).to match(/in \d+\.\d+ seconds/)
    end

    it "includes recurrence details in output" do
      output = capture_stdout do
        run_rake_task("medical_shift_recurrences:generate_pending")
      end

      expect(output).to include("ID: #{recurrence.id}")
      expect(output).to include("Frequency: #{recurrence.frequency}")
      expect(output).to include("Hospital: #{recurrence.hospital_name}")
    end

    context "with errors" do
      before do
        allow(MedicalShifts::Create).to receive(:call)
          .and_raise(StandardError.new("Test error"))
      end

      it "outputs error information" do
        output = capture_stdout do
          run_rake_task("medical_shift_recurrences:generate_pending")
        end

        expect(output).to include("ERRORS ENCOUNTERED")
        expect(output).to include("Test error")
        expect(output).to include("Recurrence ID: #{recurrence.id}")
      end

      it "still completes successfully" do
        output = capture_stdout do
          run_rake_task("medical_shift_recurrences:generate_pending")
        end

        expect(output).to include("Generation completed successfully")
      end
    end

    context "with fatal error" do
      before do
        allow(MedicalShiftRecurrences::GeneratePending).to receive(:result)
          .and_raise(StandardError.new("Fatal error"))
      end

      it "outputs fatal error and raises" do
        expect do
          capture_stdout do
            run_rake_task("medical_shift_recurrences:generate_pending")
          end
        end.to raise_error(StandardError, "Fatal error")
      end

      it "includes error details in output" do
        output = ""

        expect do
          output = capture_stdout do
            run_rake_task("medical_shift_recurrences:generate_pending")
          end
        end.to raise_error(StandardError, "Fatal error")

        expect(output).to be_a(String)
        expect(output).to include("FATAL ERROR") if output.present?
      end
    end
  end

  context "when errors occur" do
    let!(:recurrence) do
      create(
        :medical_shift_recurrence,
        user: user,
        frequency: "weekly",
        day_of_week: 1,
        start_date: Date.tomorrow,
        last_generated_until: nil
      )
    end

    before do
      allow(MedicalShifts::Create).to receive(:call)
        .and_raise(StandardError.new("Database error"))
    end

    it "outputs error information" do
      output = capture_stdout do
        run_rake_task("medical_shift_recurrences:generate_pending")
      end

      expect(output).to include("ERRORS ENCOUNTERED")
      expect(output).to include("Recurrence ID: #{recurrence.id}")
      expect(output).to include("Database error")
    end

    it "outputs recurrence details for errors" do
      output = capture_stdout do
        run_rake_task("medical_shift_recurrences:generate_pending")
      end

      expect(output).to include("User ID: #{recurrence.user_id}")
      expect(output).to include("Frequency: #{recurrence.frequency}")
      expect(output).to include("Hospital: #{recurrence.hospital_name}")
    end

    it "still completes successfully" do
      expect { run_rake_task("medical_shift_recurrences:generate_pending") }
        .to output(/Generation completed successfully/).to_stdout
    end

    # NOVO TESTE - cenário onde recorrência não existe
    context "when recurrence is deleted after error" do
      it "handles missing recurrence gracefully" do
        error = ServiceActor::Result.new(
          success?: true,
          processed: 1,
          shifts_created: 0,
          errors: [{ recurrence_id: 99_999, error: "Some error" }]
        )
        allow(MedicalShiftRecurrences::GeneratePending).to receive(:result).and_return(
          error
        )

        output = capture_stdout do
          run_rake_task("medical_shift_recurrences:generate_pending")
        end

        expect(output).to include("Recurrence ID: 99999")
        expect(output).to include("(Recurrence not found in database)")
      end
    end
  end

  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end

  def run_rake_task(task_name)
    Rake::Task[task_name].reenable
    Rake::Task[task_name].invoke
  end
end
