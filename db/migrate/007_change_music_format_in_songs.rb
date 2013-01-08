class ChangeMusicFormatInSongs < ActiveRecord::Migration
  def self.up
   change_column :songs, :music, :text
  end

  def self.down
   change_column :songs, :music, :string
  end
end