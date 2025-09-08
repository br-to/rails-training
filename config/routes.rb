Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Custom health check endpoint
  get "health", to: "health#index"

  get "me", to: "users#me"
  get "admin", to: "users#admin_info"

  resources :articles, except: [:new, :edit] do
    resources :comments, only: [:create, :update, :destroy]
  end

  resources :api_tokens, only: [:create, :destroy]

  # Defines the root path route ("/")
  # root "posts#index"
end
