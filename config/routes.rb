Rails.application.routes.draw do
  
  root 'static_pages#top'
  get  '/signup', to: 'users#new'
  resources :users #4つの基本操作（POST GET PATCH DELETE）が定義されている
end
