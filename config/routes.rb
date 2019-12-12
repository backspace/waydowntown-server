Rails.application.routes.draw do
  post 'auth', to: 'auth#find'
  post 'games/request', to: 'games#find'
  patch 'games/:id/accept', to: 'games#accept'
  patch 'games/:id/arrive', to: 'games#arrive'
  patch 'games/:id/represent', to: 'games#represent'

  patch 'games/:id/report', to: 'games#report'

  patch 'games/:id/cancel', to: 'games#cancel'
  patch 'games/:id/dismiss', to: 'games#dismiss'

  resources :games, only: [:index]
  resources :members, only: [:update]
  resources :teams, only: [:index]
end
