Rails.application.routes.draw do

  root 'static_pages#top'
  get  '/signup', to: 'users#new'
  
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  resources :users #4つの基本操作（POST GET PATCH DELETE）が定義されている
end
