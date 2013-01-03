class CreateSounds < ActiveRecord::Migration
  def self.up
    create_table :sounds do |t|
      t.string :url
      t.string :name
      t.string :family
      t.string :extra
      t.timestamps
    end
  end

  def self.down
    drop_table :sounds
  end
end
