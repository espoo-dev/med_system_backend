# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationQuery do
  let(:test_query_class) do
    Class.new(ApplicationQuery) do
      def call
        "Test Query Called"
      end
    end
  end

  before do
    stub_const("TestQuery", test_query_class)
  end

  it "calls the query object" do
    result = TestQuery.call
    expect(result).to eq("Test Query Called")
  end

  it "raises an error if call is not implemented" do
    expect do
      described_class.call
    end.to raise_error(RuntimeError, "`call` method should be implemented in concrete class")
  end
end
