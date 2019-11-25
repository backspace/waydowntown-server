Rails.application.routes.draw do
  post 'auth', to: 'auth#find'
  post 'games/request', to: 'games#find'

  resources :teams, only: [:index]
end
