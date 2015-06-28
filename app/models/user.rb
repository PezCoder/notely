class User < ActiveRecord::Base
	has_many :notes
	#Encrypt password
	has_secure_password

	#Validation
	validates :username,:email,:password,presence: true
	validates :username,:email, uniqueness: {:case_sensitive=>false}
	
	scope :recent_users,lambda { order("users.created_at DESC")} 
end
