# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  namespace :admin do
    resources :event_procedures
    resources :health_insurances
    resources :hospitals
    resources :medical_shifts
    resources :patients
    resources :procedures
    resources :users

    root to: "event_procedures#index"
  end
  extend DemoPackRoutes
  extend OauthRoutes
  mount Sidekiq::Web => "/sidekiq"

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :event_procedures, only: %i[index create update destroy]
      resources :health_insurances, only: %i[index create]
      resources :hospitals, only: %i[index create update destroy]
      resources :medical_shifts, only: %i[index create update destroy] do
        get "hospital_name_suggestion", to: "medical_shifts#hospital_name_suggestion_index", on: :collection
        get "amount_suggestions", to: "medical_shifts#amount_suggestions_index", on: :collection
      end
      resources :patients, only: %i[index create update destroy]
      resources :procedures, only: %i[index create update destroy]
      resources :users, only: [:index] do
        collection do
          delete :destroy_self
        end
      end

      get "/event_procedures_dashboard/amount_by_day", to: "event_procedures_dashboard#amount_by_day"
      get "/pdf_reports/generate", to: "pdf_reports#generate", defaults: { format: :pdf }
    end
  end
end
