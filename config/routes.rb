Rails.application.routes.draw do
  namespace :api do
    post "user", to: "user#create"
    get "user", to: "user#show"
    post "sessions", to: "sessions#create"
    namespace :user do
      post "game_events", to: "game_events#create"
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
