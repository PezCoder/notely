class Tag < ActiveRecord::Base
	has_and_belongs_to_many :notes
	scope :recent_tags,lambda { order("updated_at desc") }
end
