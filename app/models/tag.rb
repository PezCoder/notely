class Tag < ActiveRecord::Base
	has_many :tags_handlers
	has_many :notes,:through=>:tags_handlers
	has_many :users,:through=>:tags_handlers
	scope :recent_tags,lambda { order("updated_at desc") }
end
