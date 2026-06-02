Rails.application.routes.draw do
  devise_for :users,
             controllers: { registrations: "users/registrations",
                            sessions: "users/sessions",
                            confirmations: "users/confirmations",
                            passwords: "users/passwords" }

  get 'users/list', to: 'users#list'

  resources :comments, only: [:create, :update, :destroy]

  resources :notifications, only: [] do
    member do
      post :read
    end
    collection do
      post :read_all
    end
  end

  root "pages#home"
end
