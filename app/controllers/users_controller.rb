class UsersController < ApplicationController
	layout 'application'
	
	before_action :check_logged_in,:only=>[:edit,:update,:destroy]
	before_action :get_notifications,:only=>[:edit]
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
		@user = User.new(get_user_params)
		if @user.save
			flash[:notice]="Your account is created succesfully."
			redirect_to user_notes_path(@user.id)
		else
			flash[:alert]="Error while creating account ! Please try again later. "
			render('new')
		end
	end

	def edit 
		@user = User.find_by_id(params[:id])
	end

	def update
		user = User.find_by_id(params[:id])
		if user.update_attributes(get_user_params)
			flash[:notice]="Profile updated succesfully."
			redirect_to edit_user_path(user.id)
		else
			flash[:alert]="Error while updating profile ! Please, Try again later."
			@user = User.find_by_id(params[:id])
			render('edit')
		end
	end

	def destroy
		user = User.find_by_id(params[:id])
		user.destroy
		flash[:notice]="Your account has been deleted !"		
		session[:id]=nil
		session[:username]=nil
		redirect_to root_path
	end

	private

	def get_user_params
		params[:user][:username] = params[:user][:username].downcase
		params.require(:user).permit(:email,:username,:password)
	end
end
