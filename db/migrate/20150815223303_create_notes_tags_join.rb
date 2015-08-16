class CreateNotesTagsJoin < ActiveRecord::Migration
  def change
    create_table :notes_tags,{:id=>false} do |t|
    	t.integer 'note_id'
    	t.integer 'tag_id'
    	t.timestamps null: false
    end
    add_index :notes_tags,["note_id","tag_id"]
  end
end
