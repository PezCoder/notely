class Note < ActiveRecord::Base
	has_many :collaborations
	has_many :users,:through=>:collaborations
	has_and_belongs_to_many :tags

	validates :content,presence: true

	scope :recent_notes,lambda { order("notes.created_at DESC") }

end
