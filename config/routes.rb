Rails.application.routes.draw do
  post 'games', to: 'games#find'

  resources :teams, only: [:index]
end
