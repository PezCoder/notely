class AccessController < ApplicationController
	layout false
	def login 
		#show login page
	end

	def login_attempt
		if params[:username].present? && params[:password].present?
			user = User.find_by_username(params[:username].downcase)
			if user 
				puts ">>>> User is '#{user.username}'"
				auth_user = user.authenticate(params[:password])
			end
		end

		if auth_user 
			puts ">>>> AUTHORIZED USER WITH ID #{auth_user.id} & username is @#{auth_user.username}"
			session[:id]=auth_user.id
			session[:username]=auth_user.username
			flash[:notice]="Welcome, #{user.username}."
			redirect_to user_notes_path(user.id)
		else
			puts ">>>> INVALID USER "
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

