Rails.application.routes.draw do
  post 'games/request', to: 'games#find'

  resources :teams, only: [:index]
end
