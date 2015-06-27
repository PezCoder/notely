class Note < ActiveRecord::Base
	belongs_to :user
	has_many :shared_users,:dependent=>:destroy
	has_many :tags,:dependent=>:destroy

	validates :content,presence: true

	scope :recent_notes,lambda { order("notes.created_at DESC") }
end
