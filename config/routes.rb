Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :requests, only: [:index] do
    collection do
      get :query_results
    end
  end

  resources :smite_requests, only: [:index] do
    collection do
      get :query_results
    end
  end

  root to: 'requests#index'

end
