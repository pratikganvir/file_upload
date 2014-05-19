class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.string :artist_name
      t.string :title
      t.string :genere_name
      t.string :duration
      t.float :price
      t.integer :played_song
      t.string :country
      t.string :song_image
      t.string :song_file
      t.timestamps
    end
    change_table :songs do |t|
      t.attachment :song_image
      t.attachment :song_file
    end
  end

  def self.down
    drop_attached_file :songs, :song_image
    drop_attached_file :songs, :song_file
  end
end
