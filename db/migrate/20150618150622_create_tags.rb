class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
    	t.string 'tagname',:limit=>30
    	t.references 'note'
      t.timestamps null: false
    end
    add_index('tags','tagname')  
    add_index('tags','note_id')
  end
end
