# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Patients" do
  let!(:user) { create(:user) }
  let(:headers) { auth_token_for(user) }

  describe "GET ap1/v1/patients" do
    let(:path) { "/api/v1/patients" }
    let(:http_method) { :get }
    let(:params) { {} }

    context "when user is authenticated" do
      context "when there are patients" do
        let!(:patients) { create_list(:patient, 2, user:) }

        before do
          get path, headers: headers
        end

        it "returns ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns patients" do
          expect(response.parsed_body).to include(
            {
              "id" => patients.first.id,
              "name" => patients.first.name,
              "deletable" => true
            },
            {
              "id" => patients.second.id,
              "name" => patients.second.name,
              "deletable" => true
            }
          )
        end
      end

      context "when there are no patients" do
        before do
          get path, headers: headers
        end

        it "returns ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns empty array" do
          expect(response.parsed_body).to eq([])
        end
      end

      context "when has pagination via page and per_page" do
        before do
          create_list(:patient, 8, user:)
          get path, params: { page: 2, per_page: 5 }, headers: headers
        end

        it "returns only 3 patients" do
          expect(response.parsed_body.length).to eq(3)
        end
      end
    end

    include_context "when user is not authenticated"
  end

  describe "POST api/v1/patients" do
    let(:path) { "/api/v1/patients" }
    let(:http_method) { :post }
    let(:params) { { name: "John" } }

    include_context "when user is not authenticated"

    context "when user is authenticated" do
      context "when params are valid" do
        before do
          post path, params: params, headers: headers
        end

        it "returns created" do
          expect(response).to have_http_status(:created)
        end

        it "returns patient" do
          expect(response.parsed_body.symbolize_keys).to include(
            id: be_present,
            name: params[:name]
          )
        end
      end

      context "when params are invalid" do
        let(:invalid_attributes) { { name: nil } }

        before do
          post path, params: invalid_attributes, headers: headers
        end

        it "returns unprocessable_content" do
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns errors" do
          expect(response.parsed_body.symbolize_keys).to include(
            name: ["can't be blank"]
          )
        end
      end
    end
  end

  describe "PUT api/v1/patients/:id" do
    let!(:patient) { create(:patient, user: user) }
    let(:params) { { name: "John" } }
    let(:path) { "/api/v1/patients/#{patient.id}" }
    let(:http_method) { :put }

    context "when user is authenticated" do
      context "when params are valid" do
        let!(:patient) { create(:patient, user: user, name: "Old Name") }

        before do
          put path, params: { name: "New Name" }, headers: headers
        end

        it "returns ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns patient" do
          expect(response.parsed_body.symbolize_keys).to include(
            id: patient.id,
            name: "New Name"
          )
        end
      end

      context "when params are invalid" do
        before do
          put path, params: { name: nil }, headers: headers
        end

        it "returns unprocessable_content" do
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns errors" do
          expect(response.parsed_body.symbolize_keys).to include(
            name: ["can't be blank"]
          )
        end
      end
    end

    include_context "when user is not authenticated"
  end

  describe "DELETE api/v1/patients/:id" do
    let(:patient) { create(:patient, user: user) }
    let(:path) { "/api/v1/patients/#{patient.id}" }
    let(:http_method) { :delete }
    let(:params) { {} }

    context "when user is authenticated" do
      include_examples "delete request returns ok", Patient

      context "when patient cannot be destroyed" do
        let(:patient) { create(:patient) }
        let(:errors) do
          instance_double(
            ActiveModel::Errors,
            full_messages: ["Cannot delete record because of dependent event_procedures"]
          )
        end

        before do
          allow(Patient).to receive(:destroy).with(patient.id.to_s).and_return(patient)
          allow(patient).to receive_messages(destroy: false, errors: errors)
          allow(patient).to receive(:errors).and_return(errors)
        end

        it "returns unauthorized" do
          delete path, headers: headers
          expect(response).to have_http_status(:unauthorized)
        end

        it "returns errors" do
          delete path, headers: headers

          expect(response.parsed_body).to include({ "error" => "not allowed to destroy? this Patient" })
        end
      end

      context "when theres an error on destroy" do
        it "returns unprocessable_content" do
          patient = create(:patient, user: user)

          result_object = Struct.new(:success?, :error).new(
            false,
            { error: "Error message." }
          )

          allow(Patients::Destroy).to receive(:result).with(id: patient.id.to_s).and_return(result_object)

          delete "/api/v1/patients/#{patient.id}", headers: headers

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    include_context "when user is not authenticated"
  end
end
