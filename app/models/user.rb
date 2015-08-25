class User < ActiveRecord::Base
	has_many :collaborations
	has_many :notes,:through=>:collaborations
	has_many :tags,:dependent=>:destroy
	has_many :notifications
	
	#Encrypt password
	has_secure_password

	#Validation
	validates :username,:email,:password,presence: true
	validates :username,:email, uniqueness: {:case_sensitive=>false}
	
	scope :recent_users,lambda { order("users.created_at DESC")} 

	after_destroy :destroy_related_notes,:destroy_related_tags

	private 
	def destroy_related_notes
		self.notes.each do |note|
			note.destroy
			puts ">>> Note destroyed : #{note.content}"
		end
	end

	def destroy_related_tags

	end
end
