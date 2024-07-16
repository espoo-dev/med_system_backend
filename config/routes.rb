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
      resources :medical_shifts, only: %i[index create update]
      resources :patients, only: %i[index create update destroy]
      resources :procedures, only: %i[index create update destroy]
      resources :users, only: [:index]

      get "/event_procedures_dashboard/amount_by_day", to: "event_procedures_dashboard#amount_by_day"
    end
  end
end
