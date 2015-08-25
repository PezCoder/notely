class CreateTagsHandlers < ActiveRecord::Migration
  def change
    create_table :tags_handlers do |t|
    	t.references :note
    	t.references :user
    	t.references :tag
      t.timestamps null: false
    end

    add_index :tags_handlers,["user_id","note_id","tag_id"]
  end
end
