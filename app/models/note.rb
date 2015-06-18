class Note < ActiveRecord::Base
	belongs_to :user
	has_many :shared_users
	has_many :tags
end
