class Note < ActiveRecord::Base
	belongs_to :user
	has_many :shared_users,:dependent=>:destroy
	has_and_belongs_to_many :tags

	validates :content,presence: true

	scope :recent_notes,lambda { order("notes.created_at DESC") }

end
