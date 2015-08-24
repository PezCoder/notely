Rails.application.routes.draw do

  resources :users do 
  	resources :notes 
  	member do 
  		get :accept,to:'notes#accept_notification'
  		get :reject,to:'notes#reject_notification'
  	end	
  end
  
  get '/login',to: 'access#login'
  post '/login_attempt',to: 'access#login_attempt'
  get '/logout',to: 'access#logout'

  root "notes#index"

end
