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
  end

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/admin', to: 'admin#index', as: 'admin'

  root to: "welcome#index"
end
