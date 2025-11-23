# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShiftRecurrences::NeedsGenerationQuery do
  let(:user) { create(:user) }
  let(:target_date) { 2.months.from_now.to_date }

  describe "#call" do
    context "with recurrences that need generation" do
      let!(:never_generated) do
        create(
          :medical_shift_recurrence,
          user: user,
          last_generated_until: nil
        )
      end

      let!(:old_generation) do
        create(
          :medical_shift_recurrence,
          user: user,
          last_generated_until: 1.month.from_now.to_date
        )
      end

      let!(:up_to_date) do
        create(
          :medical_shift_recurrence,
          user: user,
          last_generated_until: 2.months.from_now.to_date
        )
      end

      let!(:deleted_recurrence) do
        create(
          :medical_shift_recurrence, :deleted,
          user: user,
          last_generated_until: nil
        )
      end

      it "includes recurrences never generated" do
        result = described_class.call(target_date: target_date)

        expect(result).to include(never_generated)
      end

      it "includes recurrences with old generation" do
        result = described_class.call(target_date: target_date)

        expect(result).to include(old_generation)
      end

      it "excludes up-to-date recurrences" do
        result = described_class.call(target_date: target_date)

        expect(result).not_to include(up_to_date)
      end

      it "excludes deleted recurrences" do
        result = described_class.call(target_date: target_date)

        expect(result).not_to include(deleted_recurrence)
      end

      it "returns correct count" do
        result = described_class.call(target_date: target_date)

        expect(result.count).to eq(2)
      end
    end

    context "with different target dates" do
      let!(:recurrence) do
        create(
          :medical_shift_recurrence,
          user: user,
          last_generated_until: 2.months.from_now.to_date
        )
      end

      it "includes recurrence when target_date is after last_generated_until" do
        target = 3.months.from_now.to_date
        result = described_class.call(target_date: target)

        expect(result).to include(recurrence)
      end

      it "excludes recurrence when target_date is before last_generated_until" do
        target = 1.month.from_now.to_date
        result = described_class.call(target_date: target)

        expect(result).not_to include(recurrence)
      end

      it "excludes recurrence when target_date equals last_generated_until" do
        target = recurrence.last_generated_until
        result = described_class.call(target_date: target)

        expect(result).not_to include(recurrence)
      end
    end

    context "with custom relation" do
      let!(:user1_recurrence) do
        create(
          :medical_shift_recurrence,
          user: user,
          last_generated_until: nil
        )
      end

      let!(:user2_recurrence) do
        other_user = create(:user)
        create(
          :medical_shift_recurrence,
          user: other_user,
          last_generated_until: nil
        )
      end

      it "respects the provided relation scope" do
        user_scope = MedicalShiftRecurrence.where(user: user)
        result = described_class.call(target_date: target_date, relation: user_scope)

        expect(result).to include(user1_recurrence)
        expect(result).not_to include(user2_recurrence)
      end
    end

    context "with no recurrences" do
      it "returns empty relation" do
        result = described_class.call(target_date: target_date)

        expect(result).to be_empty
      end
    end
  end
end
