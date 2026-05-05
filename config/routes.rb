# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    root 'dashboard#index'
    resources :products

    resources :orders, only: %i[index show] do
      post :change_status, on: :member
      post :generate_offer, on: :member
      post :apply_discount, on: :member
      post :mark_paid, on: :member
      post :send_offer, on: :member
    end
    resources :companies, only: %i[index new create edit update]
    resources :reports, only: [:index] do
      collection do
        get :sales
        get :top_products
        get :top_partners
        get :order_statuses
      end
    end
  end

  root 'home#index'

  resource :profile, only: [:show], controller: 'profile'

  resources :products, only: %i[index show]

  resources :orders, only: %i[index show new create] do
    collection do
      post :add_item
    end

    post :submit, on: :member
    patch :update_delivery_address, on: :member
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
