class TagsHandler < ActiveRecord::Base
	belongs_to :tag
	belongs_to :user
	belongs_to :note

	scope :recent_handlers,lambda{ order("tags_handlers.updated_at desc") }
end
