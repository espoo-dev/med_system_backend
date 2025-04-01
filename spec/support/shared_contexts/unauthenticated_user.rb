# frozen_string_literal: true

RSpec.shared_context "when user is not authenticated" do
  before do
    get routes_path, params: {}, headers: {}
  end
end
