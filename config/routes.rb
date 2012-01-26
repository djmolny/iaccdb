Iac::Application.routes.draw do

  namespace :admin do
    root :to => "contests#index"
    resources :contests, :except => [:new, :create]
    resources :manny_synchs, :only => [:index, :destroy]
  end

  get "pages/notes"

  resources :contests, :only => [:index, :show]
  root :to => "contests#index"

  resources :pilots, :only => [:index, :show] do
    resources :scores, :only => [:show]
  end

  resources :judges, :only => [:index, :show]

  resources :flights, :only => [:show]

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all routes lay out with "rake routes"

end
