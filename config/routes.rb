Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'pages#index'

  namespace :api do
    get 'pages/home', to: 'pages#home'
    resources :posts, only: [:index]
  end

  get '*anything' => 'pages#index'
end
