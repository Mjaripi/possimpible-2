Rails.application.routes.draw do

  resources :projects, only: [:index] do
    collection do
      post '/load_projects', to: 'projects#load_projects'
      get '/show_projects', to: 'projects#show_projects'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "projects#index"
end
