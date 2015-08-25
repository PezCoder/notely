class User < ActiveRecord::Base
	has_many :collaborations
	has_many :notes,:through=>:collaborations

	has_many :tags_handlers
	has_many :tags,:through=>:tags_handlers
	
	has_many :notifications
	
	#Encrypt password
	has_secure_password

	#Validation
	validates :username,:email,:password,presence: true
	validates :username,:email, uniqueness: {:case_sensitive=>false}
	
	scope :recent_users,lambda { order("users.created_at DESC")} 

	before_destroy :destroy_related_notes

	private 
	def destroy_related_notes
		self.notes.each do |note|
			note.destroy
		end
	end

end
