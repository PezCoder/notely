class User < ActiveRecord::Base
	has_many :collaborations
	has_many :notes,:through=>:collaborations
	has_many :tags
	#Encrypt password
	has_secure_password

	#Validation
	validates :username,:email,:password,presence: true
	validates :username,:email, uniqueness: {:case_sensitive=>false}
	
	scope :recent_users,lambda { order("users.created_at DESC")} 
end
