class AccessController < ApplicationController
	def login 
		#show login page
	end

	def login_attempt
		if params[:username].present? && params[:password].present? && params[:email].present?
			user = User.find_by_username(params[:username].downcase)
			if user 
				auth_user = user.authenticate(params[:password])
			end
		end

		if auth_user 
			session[:id]=auth_user.id
			session[:username]=auth_user.username
			flash[:notice]="Welcome, #{user.username}."
			redirect_to user_notes_path(user.id)
		else
			flash[:alert]="Invalid Username or Password ! "
			render('login')
		end

	end

	def logout
		session[:id]=nil
		session[:username]=nil
		flash[:notice]="You have been logged out."
		redirect_to root_path
	end
end

