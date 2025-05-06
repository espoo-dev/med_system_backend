# frozen_string_literal: true

RSpec.shared_examples "delete request returns ok" do |model_class|
  it "returns ok" do
    send(http_method, path, params: params, headers: headers)

    expect(response.parsed_body[:message]).to eq("#{model_class} deleted successfully.")
    expect(response).to have_http_status(:ok)
  end
end
