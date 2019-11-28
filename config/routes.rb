Rails.application.routes.draw do
  post 'auth', to: 'auth#find'
  post 'games/request', to: 'games#find'
  post 'games/:id/accept', to: 'games#accept'

  resources :teams, only: [:index]
end
