class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
    	t.references :user
    	t.references :note
    	t.boolean 'is_seen',:default=>false
    	t.string 'from_user'
      #notification for user removed from collaboration
      t.boolean 'is_removed',:default=>false 
      t.boolean 'rejected',:default=>false
      t.timestamps null: false
    end
    add_index("notifications",["user_id","note_id"])
  end
end
