Rails.application.routes.draw do
  resources :pets

  root "pets#index"
end
