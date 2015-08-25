class Notification < ActiveRecord::Base
	belongs_to :note
	belongs_to :user

	scope :recent_notifications,lambda { order("notifications.created_at DESC")}
end
