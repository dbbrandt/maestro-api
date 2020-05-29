Rails.application.routes.draw do

  namespace :api do
    resources :goals do
      member do
        delete :purge
        get :presigned_url
      end
      resources :interactions do
        member do
          get :check_answer
          get :presigned_url
          post :submit_review
        end
      end
      resources :import_files do
        member do
          post :generate
        end
      end
      resources :rounds do
        resources :round_responses
      end
    end

    # Interactions are only accessible through goals and content through interactions.
    resources :interactions, only: [] do
      resources :contents
    end

    resources :import_files do
      resources :import_rows
    end

    resources :users do
      member do
        get :presigned_url
        delete :purge
      end
    end
    post 'authorize', to: 'auth#authorize', as: 'authorize'
  end
  root  :to => 'api/goals#index'
end
