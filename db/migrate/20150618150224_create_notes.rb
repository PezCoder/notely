class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
    	t.text 'content'
      t.timestamps null: false
    end
    add_index('notes','user_id')
  end
end
