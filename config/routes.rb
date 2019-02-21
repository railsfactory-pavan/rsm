Rails.application.routes.draw do
  root 'events#index'
  resources :events
  devise_for :users

  namespace :api do
    namespace :v1 do
      resources :events

      get '/events', to: 'events#index'
      get '/events/:id', to: 'events#show'
    end
  end
end
