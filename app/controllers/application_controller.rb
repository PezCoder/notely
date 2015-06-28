class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private 
  def check_logged_in
  	if session[:id] && session[:username]
  		return true
  	else 
  		flash[:warning]="Please login !"
  		redirect_to login_access_path
  		return false
  	end
  end
end
