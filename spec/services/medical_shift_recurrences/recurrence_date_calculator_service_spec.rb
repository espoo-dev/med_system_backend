# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShiftRecurrences::RecurrenceDateCalculatorService do
  let(:user) { create(:user) }

  describe "#dates_until" do
    let(:target_date) { 3.months.from_now.to_date }

    context "with deleted recurrence" do
      let(:recurrence) { create(:medical_shift_recurrence, :deleted, user: user) }

      it "returns empty array" do
        service = described_class.new(recurrence)
        result = service.dates_until(target_date)

        expect(result).to be_empty
      end
    end

    context "with weekly recurrence" do
      let(:start_date) { Date.current.next_occurring(:monday) }
      let(:recurrence) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 1, # Monday
          start_date: start_date
        )
      end

      it "generates dates every week" do
        service = described_class.new(recurrence)
        dates = service.dates_until(2.months.from_now.to_date)

        expect(dates).to all(satisfy { |d| d.wday == 1 })
      end

      it "skips the start_date when it matches day_of_week" do
        service = described_class.new(recurrence)
        dates = service.dates_until(2.months.from_now.to_date)

        expect(dates.first).to eq(start_date + 7.days)
      end

      it "spaces dates 7 days apart" do
        service = described_class.new(recurrence)
        dates = service.dates_until(2.months.from_now.to_date)

        dates.each_cons(2) do |date1, date2|
          expect(date2 - date1).to eq(7)
        end
      end

      context "when start_date is not the target weekday" do
        let(:start_date) { Date.current.next_occurring(:wednesday) }

        it "first date is the next monday after start_date" do
          service = described_class.new(recurrence)
          dates = service.dates_until(2.months.from_now.to_date)

          expect(dates.first).to be > start_date
          expect(dates.first.wday).to eq(1)
        end
      end
    end

    context "with biweekly recurrence" do
      let(:start_date) { Date.current.next_occurring(:friday) }
      let(:recurrence) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "biweekly",
          day_of_week: 5, # Friday
          start_date: start_date
        )
      end

      it "generates dates every two weeks" do
        service = described_class.new(recurrence)
        dates = service.dates_until(3.months.from_now.to_date)

        dates.each_cons(2) do |date1, date2|
          expect(date2 - date1).to eq(14)
        end
      end

      it "skips the start_date and starts 14 days later" do
        service = described_class.new(recurrence)
        dates = service.dates_until(2.months.from_now.to_date)

        expect(dates.first).to eq(start_date + 14.days)
      end

      context "when start_date is not the target weekday" do
        let(:start_date) { Date.current.next_occurring(:monday) }

        it "first date is the next friday after start_date" do
          service = described_class.new(recurrence)
          dates = service.dates_until(2.months.from_now.to_date)

          expect(dates.first).to be > start_date
          expect(dates.first.wday).to eq(5)
        end
      end
    end

    context "with monthly_fixed_day recurrence" do
      let(:start_date) { Date.new(2026, 1, 15) }
      let(:recurrence) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "monthly_fixed_day",
          day_of_week: nil,
          day_of_month: 15,
          start_date: start_date
        )
      end

      it "generates dates on the same day each month" do
        service = described_class.new(recurrence)
        dates = service.dates_until(Date.new(2026, 6, 30))

        dates.each do |date|
          expect(date.day).to eq(15)
        end
      end

      it "skips the start_date when it matches day_of_month" do
        service = described_class.new(recurrence)
        dates = service.dates_until(Date.new(2026, 6, 30))

        expect(dates.first).to eq(Date.new(2026, 2, 15))
      end

      context "when day is 31" do
        let(:recurrence) do
          create(
            :medical_shift_recurrence,
            user: user,
            frequency: "monthly_fixed_day",
            day_of_week: nil,
            day_of_month: 31,
            start_date: Date.new(2026, 1, 31)
          )
        end

        it "skips months without day 31" do
          service = described_class.new(recurrence)
          dates = service.dates_until(Date.new(2026, 6, 30))

          months = dates.map(&:month)

          expect(months).to include(3, 5)
          expect(months).not_to include(2, 4, 6)
        end
      end

      context "when start_date day is before target day" do
        let(:start_date) { Date.new(2026, 1, 10) }

        it "first date is in the current month" do
          service = described_class.new(recurrence)
          dates = service.dates_until(Date.new(2026, 6, 30))

          expect(dates.first).to eq(Date.new(2026, 1, 15))
        end
      end

      context "when start_date day is after target day" do
        let(:start_date) { Date.new(2026, 1, 20) }

        it "first date is in the next month" do
          service = described_class.new(recurrence)
          dates = service.dates_until(Date.new(2026, 6, 30))

          expect(dates.first).to eq(Date.new(2026, 2, 15))
        end
      end
    end

    context "with end_date" do
      let(:recurrence) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 3,
          start_date: Date.tomorrow,
          end_date: 1.month.from_now.to_date
        )
      end

      it "does not generate dates beyond end_date" do
        service = described_class.new(recurrence)
        dates = service.dates_until(6.months.from_now.to_date)

        expect(dates).to all(be <= recurrence.end_date)
      end

      it "respects end_date over target_date" do
        service = described_class.new(recurrence)
        dates = service.dates_until(6.months.from_now.to_date)

        expect(dates.last).to be <= 1.month.from_now.to_date
      end
    end

    context "with last_generated_until set" do
      let(:recurrence) do
        create(
          :medical_shift_recurrence,
          user: user,
          frequency: "weekly",
          day_of_week: 1,
          start_date: Date.current.next_occurring(:monday),
          last_generated_until: 1.month.from_now.to_date
        )
      end

      it "starts from the next occurrence after last_generated_until" do
        service = described_class.new(recurrence)
        dates = service.dates_until(3.months.from_now.to_date)

        expect(dates.first).to be > recurrence.last_generated_until
      end

      it "does not include dates before last_generated_until" do
        service = described_class.new(recurrence)
        dates = service.dates_until(3.months.from_now.to_date)

        expect(dates).to all(be > recurrence.last_generated_until)
      end
    end
  end
end
