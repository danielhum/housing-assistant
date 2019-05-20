Rails.application.routes.draw do
  resources :houses, only: :index
end
