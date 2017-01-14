Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'pages#index'

  get '/*' => 'pages#index'

  namespace :api do
    resources :posts, only: [:index]
  end
end
