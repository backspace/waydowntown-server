Rails.application.routes.draw do
  post 'auth', to: 'auth#find'
  post 'games/request', to: 'games#find'
  patch 'games/:id/accept', to: 'games#accept'

  resources :games, only: [:index]
  resources :teams, only: [:index]
end
