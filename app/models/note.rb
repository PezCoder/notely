class Note < ActiveRecord::Base
	has_many :collaborations
	has_many :users,:through=>:collaborations

	has_many :tags_handlers
	has_many :tags,:through=>:tags_handlers
	
	has_many :notifications

	validates :content,presence: true

	scope :recent_notes,lambda { order("notes.created_at DESC") }

	#active record callbacks
	before_destroy :destroy_related_tags,:destroy_related_notifications,:destroy_its_collabs
	after_update :touch_tags
	private
	def destroy_related_tags
		users = self.users
		tags = self.tags
		users.each do |user|
			tags.each do |tag|
				handler = TagsHandler.where(:user=>user,:tag=>tag,:note=>self)
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
