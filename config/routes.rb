Rails.application.routes.draw do
  resources :districts do
    resources :schools, only: %i[index show] do
      resources :overview, only: [:index]
      resources :categories, only: [:show], path: 'browse'
      resources :analyze, only: [:index]
    end
  end

  get :reports, to: 'reports#index'
  get 'reports/gps', to: 'gps#index'

  get '/welcome', to: 'home#index'
  root to: 'home#index'
end
