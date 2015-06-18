class User < ActiveRecord::Base
	has_many :notes
	#Encrypt password
	has_secure_password

end
