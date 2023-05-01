Rails.application.routes.draw do
#  get 'session/new'
#   get 'session/create'
#   get 'session/destroy'
#   get 'user/new'
#   get 'user/create'
#   get 'ecom/index'
#   get '/index', to: 'ecom#index'
#   post '/users', to: 'user#create'
#   post '/sessions', to: 'session#create'
#   get '/enter', to: 'user#new'
#   get '/login', to: 'session#new' 
#   delete '/logout', to: 'session#destroy'
#   get 'show/:id', to: 'ecom#show', as: :show
  get 'ecom/', to: 'ecom#index'
  get 'ecom/page', to: 'ecom#page'
  post 'ecom/show', to: 'ecom#show'
  get 'session/logout', to: 'session#destroy'
  get 'ecom/category_filter', to: 'ecom#category_filter'
  get 'ecom/product_filter', to: 'ecom#product_filter'
  get 'ecom/variant_filter', to: 'ecom#variant_filter'
  get 'ecom/multi_filter', to: 'ecom#multi_filter'
  get 'ecom/price_filter', to: 'ecom#price_filter'
  get 'ecom/price_sort_by', to: 'ecom#price_sort_by'
  #post 'user', to: 'user#create'
  resources :user
  resources :session
  resources :ecom 
  post 'user', to: 'user#create'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
