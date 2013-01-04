class AddOwnerToSongs < ActiveRecord::Migration
  def up
    add_column :songs, :owner, :string
  end

  def down
    remove_column :songs, :owner
  end
end