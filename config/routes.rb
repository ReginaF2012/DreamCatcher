Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'dreams#index'
  resources :users, only: [:show, :create] do
    resources :symbolisms, only: [:show, :index]
    resources :dreams, except: [:index] do
      resources :dream_symbolisms, only: [:new, :create, :edit, :destroy, :update]
    end
  end
  resources :symbolisms, only: [:show, :index]
  resources :dreams, only: [:index]
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/signup', to: 'users#new', as: 'signup'
  get '/login', to: 'sessions#new', as: 'login'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy', as: 'logout'
end
