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
  post '/cart/rack_session', to: 'rack_session#create'
  resources :cart, only: %i[create show], controller: 'carts' do
    collection do
      get '', to: 'carts#show'
      post 'add_item', to: 'carts#add_item'
    end
  end
end
