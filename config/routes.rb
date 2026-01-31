Rails.application.routes.draw do
  get "products/index"
  get "products/show"
  devise_for :users

  namespace :admin do
    get "products/index"
    get "products/new"
    get "products/create"
    get "products/edit"
    get "products/update"
    get "products/destroy"
    root "dashboard#index"
    resources :products
  end

  root "home#index"

  resource :profile, only: [:show], controller: "profile"
  resources :products, only: [:index, :show]


  get "up" => "rails/health#show", as: :rails_health_check
end