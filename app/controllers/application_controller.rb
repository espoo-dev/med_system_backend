# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.admin?
        admin_health_insurances_path
      else
        api_v1_event_procedures_path
      end
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end
end
