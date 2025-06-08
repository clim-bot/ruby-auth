Rails.application.routes.draw do
  resources :posts

  # Sessions (login/logout)
  resource :session, only: [ :new, :create, :destroy ], controller: "sessions"
  get    "/login",  to: "sessions#new",     as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  # Password reset
  resources :passwords, param: :token

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "posts#index"
end
