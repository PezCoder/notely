class CreateSharedUsers < ActiveRecord::Migration
  def change
    create_table :shared_users do |t|
    	t.string 'username',:limit=>50
    	t.references 'note'
      t.timestamps null: false
    end
    add_index('shared_users','note_id')
  end
end
