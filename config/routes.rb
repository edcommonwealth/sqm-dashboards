Rails.application.routes.draw do
  resources :districts
  
  resources :schools do
    resources :recipients
  end

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html



  root to: "welcome#index"
end
