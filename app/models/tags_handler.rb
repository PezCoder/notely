class TagsHandler < ActiveRecord::Base
	belongs_to :tag
	belongs_to :user
	belongs_to :note
end
