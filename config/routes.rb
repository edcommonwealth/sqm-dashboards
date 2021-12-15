Rails.application.routes.draw do
  scope module: 'legacy', as: 'legacy' do
    resources :question_lists
    resources :questions
    resources :categories
    resources :districts
    resources :schools do
      resources :recipient_lists, as: 'legacy_recipient_lists'
      resources :recipients, as: 'legacy_recipients' do
        collection do
          get :import
          post :import
        end
      end
      resources :schedules, as: 'legacy_schedules'
      resources :categories, only: [:show], as: 'legacy_categories'
      resources :questions, only: [:show], as: 'legacy_questions'
      get :admin
    end

    get '/admin', to: 'admin#index', as: 'admin'
    post '/twilio', to: 'attempts#twilio'
  end

  resources :districts do
    resources :schools, only: %i[index show] do
      resources :overview, only: [:index]
      resources :categories, only: [:show], path: 'browse'
    end
  end

  devise_for :users, class_name: 'Legacy::User'
  as :user do
    get 'users', to: 'legacy/users#show', as: :user_root # Rails 3
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/welcome', to: 'home#index'
  root to: 'legacy/welcome#index'
end
