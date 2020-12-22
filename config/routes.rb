Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show, :create] do
        member do
          get 'availability'
          get 'events'
        end
      end
      resources :events, only: [:index, :show, :create] do
        member do
          get 'invitees'
          get 'rsvps'
          put 'users'
          put 'rsvp'
        end
      end
    end
  end
end
