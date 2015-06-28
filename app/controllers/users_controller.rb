class UsersController < ApplicationController
	def index
		@users = User.recent_users
	end

	def show
		@user = User.find_by_id(params[:id])
	end

	def new
		#registration
		@user = User.new
	end

	def create 
		user = User.new(get_user_params)
		if user.save
			flash[:notice]="Your account is created succesfully !"
			redirect_user notes_path
		else
			flash[:alert]="Something went wrong :( Please try again later ! "
			@user = User.new
			render('new')
		end
	end
end
