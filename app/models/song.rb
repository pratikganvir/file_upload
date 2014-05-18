class Song < ActiveRecord::Base
  has_attached_file :song_image, :styles => { :small => "150x150>" },
    :url  => "/assets/songs/images/:id/:style/:basename.:extension",
    :path => ":rails_root/public/assets/songs/images/:id/:style/:basename.:extension"

   has_attached_file :song_file, :styles => { :small => "150x150>" },
    :url  => "/assets/songs/file/:id/:style/:basename.:extension",
    :path => ":rails_root/public/assets/songs/file/:id/:style/:basename.:extension"

  #validates_attachment_presence :song_image
  #validates_attachment_presence :song_file
  validates_attachment_content_type :song_image, :content_type => ['image/jpeg', 'image/png']
  validates_attachment_presence :song_file,  {:content_type => ["audio/mpeg", "audio/mp3"] }
end
