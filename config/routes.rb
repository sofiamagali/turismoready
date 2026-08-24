Rails.application.routes.draw do
  devise_for :users
  resources :destinations, except: :destroy do
    patch :toggle_active, on: :member
  end
  root "home#index"
end
