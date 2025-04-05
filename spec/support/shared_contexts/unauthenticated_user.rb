# frozen_string_literal: true

RSpec.shared_context "when user is not authenticated" do
  before do
    send(http_method, path, params: params, headers: {})
  end

  it "returns unauthorized" do
    expect(response).to have_http_status(:unauthorized)
  end

  it "returns error message" do
    expect(response.parsed_body["error_description"]).to eq(["Invalid token"])
  end
end
