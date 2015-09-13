class Note < ActiveRecord::Base
	has_many :collaborations
	has_many :users,:through=>:collaborations

	has_many :tags_handlers
	has_many :tags,:through=>:tags_handlers
	
	has_many :notifications

	validates :content,presence: true

	scope :recent_notes,lambda { order("notes.updated_at DESC") }

	#active record callbacks
	before_destroy :destroy_related_tags,:destroy_related_notifications,:destroy_its_collabs
	after_update :touch_tags
	private
	def destroy_related_tags
		users = self.users
		users.each do |user|
			tag_handlers = TagsHandler.where(:user=>user,:note=>self)
			tag_handlers.each do |tag_handler|
				tag = tag_handler.tag
				puts ">>>> #{user.username}-#{tag.tagname}- $$$$$#{self.content}$$$$$ <<<<<<<"
				handler = TagsHandler.where(:user=>user,:tag=>tag,:note=>self)
				puts ">>>>>>> #{handler.length} >> #{handler[0]}"
				handler[0].destroy
			end
		end
	end

	def destroy_its_collabs
		self.collaborations.each do |collab|
			collab.destroy
		end
	end

	def destroy_related_notifications
		self.notifications.each do |notification|
			notification.destroy
		end
	end
	def touch_tags
		self.tags.each do |tag|
			tag.touch
		end
	end

end
