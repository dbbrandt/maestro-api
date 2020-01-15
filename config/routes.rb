Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  Rails.application.routes.draw do


    namespace :api do
      resources :goals do
        member do
          delete :purge
        end
        resources :interactions do
          member do
            get :check_answer
            post :submit_review
          end
        end
        resources :import_files do
          member do
            post :generate
          end
        end
        resource :rounds do
          resource :round_responses
        end
      end

      # Interactions are only accessible through goals and content through interactions.
      resources :interactions, only: [] do
        resources :contents
      end

      resources :import_files do
        resources :import_rows
      end
    end
  end
  root  :to => 'api/goals#index'
end
