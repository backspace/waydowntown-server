Rails.application.routes.draw do
  jsonapi_resources :teams, only: [:index]
end
