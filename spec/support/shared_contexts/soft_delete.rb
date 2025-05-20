# frozen_string_literal: true

RSpec.shared_examples "acts as paranoid" do |record_name|
  let(:record) { send(record_name) }

  before { record.destroy }

  it "soft deletes the record" do
    expect(record.deleted_at).to be_present
    expect(described_class.with_deleted).to include(record)
  end

  it "does not include the record in the default scope" do
    expect(described_class.all).not_to include(record)
  end

  it "includes the record in the default scope when with_deleted is called" do
    expect(described_class.with_deleted).to include(record)
  end

  it "restores a soft deleted record" do
    record.recover!
    expect(record.deleted_at).to be_nil
    expect(described_class.all).to include(record)
  end
end
