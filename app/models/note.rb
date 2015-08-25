class Note < ActiveRecord::Base
	has_many :collaborations
	has_many :users,:through=>:collaborations
	has_and_belongs_to_many :tags
	has_many :notifications

	validates :content,presence: true

	scope :recent_notes,lambda { order("notes.created_at DESC") }

	#active record callbacks
	after_destroy :destroy_related_tags
	after_update :touch_tags
	private
	def destroy_related_tags
		self.tags.each do |tag|
			tag.destroy
			puts ">> Destroying #{tag.tagname}"
		end
	end

	def touch_tags
		note.tags.touch
	end

end
