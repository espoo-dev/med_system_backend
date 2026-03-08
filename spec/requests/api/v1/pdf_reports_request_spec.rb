# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PdfReports" do
  describe "GET api/v1/pdf_reports/generate" do
    let(:user) { create(:user) }
    let(:headers) { auth_token_for(user) }
    let(:path) { api_v1_pdf_reports_generate_path }

    context "when entity_name is missing" do
      it "returns a bad request error" do
        get path, headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body["error"]).to eq("You must inform the `entity_name` parameter")
      end
    end

    context "when entity_name is 'event_procedures'" do
      before do
        entity_name = "event_procedures"
        get path, params: { entity_name: entity_name }, headers: headers
      end

      it "returns a PDF file" do
        expect(response.content_type).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to include("inline")
        expect(response.body).not_to be_empty
      end

      it "includes correct filename" do
        expect(response.headers["Content-Disposition"]).to include(
          "filename=\"#{Time.zone.now.strftime('%d%m%Y')}_report.pdf\""
        )
      end
    end

    context "when entity_name is 'medical_shifts'" do
      before do
        entity_name = "medical_shifts"
        get path, params: { entity_name: entity_name }, headers: headers
      end

      it "returns a PDF file" do
        expect(response.content_type).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to include("inline")
        expect(response.body).not_to be_empty
      end

      it "includes correct filename" do
        expect(response.headers["Content-Disposition"]).to include(
          "filename=\"#{Time.zone.now.strftime('%d%m%Y')}_report.pdf\""
        )
      end
    end

    context "with hide_values param" do
      it "returns a PDF for event_procedures" do
        create(:event_procedure, user: user)
        get path, params: { entity_name: "event_procedures", hide_values: "true" }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/pdf")
      end

      it "returns a PDF for medical_shifts" do
        create(:medical_shift, user: user)
        get path, params: { entity_name: "medical_shifts", hide_values: "true" }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/pdf")
      end
    end

    context "with ids param" do
      it "returns PDF with only selected event_procedures" do
        procedures = create_list(:event_procedure, 3, user: user)
        selected = procedures.first(2)
        get path, params: { entity_name: "event_procedures", ids: selected.map(&:id) }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/pdf")
      end

      it "returns PDF with only selected medical_shifts" do
        shifts = create_list(:medical_shift, 3, user: user)
        selected = shifts.first(2)
        get path, params: { entity_name: "medical_shifts", ids: selected.map(&:id) }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/pdf")
      end
    end
  end
end
