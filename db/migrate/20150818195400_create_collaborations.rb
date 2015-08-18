class CreateCollaborations < ActiveRecord::Migration
  def change
    create_table :collaborations do |t|
    	t.boolean "is_admin"
    	t.references :user
    	t.references :note
      t.timestamps null: false
    end
    add_index("collaborations",['user_id','note_id'])
  end
end
