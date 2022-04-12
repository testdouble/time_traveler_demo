Rails.application.routes.draw do
  resources :moon_landings

  root "moon_landings#index"
end
