Rails.application.routes.draw do
  resources :question_lists
  resources :questions
  resources :categories
  resources :districts

  resources :schools do
    resources :recipient_lists
    resources :recipients do
      collection do
        get :import
        post :import
      end
    end
    resources :schedules
    resources :categories, only: [:show]
    resources :questions, only: [:show]
    get :admin
  end

  # resources :attempts, only: [:get, :update]

  devise_for :users
  as :user do
    get 'users', :to => 'users#show', :as => :user_root # Rails 3
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/admin', to: 'admin#index', as: 'admin'
  post '/twilio', to: 'attempts#twilio'

  root to: "welcome#index"
end
