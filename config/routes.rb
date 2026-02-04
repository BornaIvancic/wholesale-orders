Rails.application.routes.draw do
  get "orders/index"
  get "orders/show"
  get "orders/new"
  get "orders/create"
  devise_for :users

  namespace :admin do
    get "orders/index"
    get "orders/show"
    root "dashboard#index"
    resources :products
    resources :orders, only: [:index, :show]
  end

  root "home#index"

  resource :profile, only: [:show], controller: "profile"

  resources :products, only: [:index, :show]
  resources :orders, only: [:index, :show, :new, :create]

  get "up" => "rails/health#show", as: :rails_health_check
end