# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    def test_after_sign_in_path_for
      render plain: after_sign_in_path_for(current_user)
    end

    def test_after_sign_up_path_for
      render plain: after_sign_up_path_for(current_user)
    end
  end

  let(:admin_user) { create(:user, admin: true) }
  let(:regular_user) { create(:user, admin: false) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    routes.draw do
      get "test_after_sign_in_path_for" => "anonymous#test_after_sign_in_path_for"
      get "test_after_sign_up_path_for" => "anonymous#test_after_sign_up_path_for"
    end
  end

  describe "#after_sign_in_path_for" do
    context "when user is admin" do
      let(:current_user) { admin_user }

      it "redirects to admin path" do
        get :test_after_sign_in_path_for
        expect(response.body).to eq("/admin/health_insurances")
      end
    end

    context "when user is not admin" do
      let(:current_user) { regular_user }

      it "redirects to api event procedures path" do
        get :test_after_sign_in_path_for
        expect(response.body).to eq("/api/v1/event_procedures")
      end
    end
  end

  describe "#after_sign_up_path_for" do
    let(:current_user) { regular_user }

    it "returns same path as after_sign_in_path_for" do
      get :test_after_sign_up_path_for
      expect(response.body).to eq("/api/v1/event_procedures")
    end
  end
end
