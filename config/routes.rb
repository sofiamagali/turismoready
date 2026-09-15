Rails.application.routes.draw do
  devise_for :users
  resource :profile, only: :show
  resources :destinations, except: :destroy do
    patch :toggle_active, on: :member
  end
  resources :trips, except: :destroy do
    patch :toggle_active, on: :member
    resources :reservations, only: %i[new create]
  end
  resources :reservations, only: %i[show edit update] do
    patch :confirm, on: :member
    post :checkout, on: :member
    post :fake_payment, on: :member
  end
  post "mercadopago/webhook", to: "mercadopago#webhook"
  root "home#index"
end
