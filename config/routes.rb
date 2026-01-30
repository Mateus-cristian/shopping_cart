# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get 'up' => 'rails/health#show', as: :rails_health_check
  get '/health', to: 'application#health'

  root 'rails/health#show'
  resources :carts, only: [:create] do
    collection do
      get '/', to: 'carts#show'
    end
  end
end
