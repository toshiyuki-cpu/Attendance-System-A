Rails.application.routes.draw do

  root 'static_pages#top'
  get  '/signup', to: 'users#new'
  
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  resources :users do #4つの基本操作（POST GET PATCH DELETE）が定義されている
  
  member do #生成されたurlにuserを識別するための:idが自動で追加されます
    get 'edit_basic-info'
    patch 'update_basic_info'
  end
 end
end
