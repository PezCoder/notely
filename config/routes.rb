Rails.application.routes.draw do

  resources :users do 
  	resources :notes
  end
  root "notes#index"

end
