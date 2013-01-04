class AddUserToSongs < ActiveRecord::Migration
  def up
    remove_column :songs, :owner
    add_column :songs, :user_id, :integer
  end

  def down
  	add_column :songs, :owner, :string
  	remove_column :songs, user_id
  end
end