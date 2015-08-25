class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
    	t.string 'tagname',:limit=>30
      t.timestamps null: false
    end
    add_index('tags','tagname')  
  end
end
