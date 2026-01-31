Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    root "dashboard#index"
  end

  root "home#index"

  resource :profile, only: [:show], controller: "profile"

  get "up" => "rails/health#show", as: :rails_health_check
end