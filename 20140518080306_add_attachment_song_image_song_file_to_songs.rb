class AddAttachmentSongImageSongFileToSongs < ActiveRecord::Migration
  def self.up
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
