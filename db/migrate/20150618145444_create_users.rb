class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
    	t.string 'username',:limit=>50
    	t.string 'email',:limit=>50
    	t.text 'password_digest'
      t.timestamps null: false
    end
    add_index('users','username')
  end
end
