Rails.application.routes.draw do

  resources :users do 
  	resources :notes 
  	member do 
  		get :accept,to:'notes#accept_notification'
  		get :reject,to:'notes#reject_notification'
      get :suggest,to:'notes#suggest_tags'
  	end	
  end
  
  get '/login',to: 'access#login'
  post '/login_attempt',to: 'access#login_attempt'
  get '/logout',to: 'access#logout'
  get '/register',to: 'users#new'
  root "notes#index"

end
