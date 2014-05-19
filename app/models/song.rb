#require 'mime/types'

class Song < ActiveRecord::Base
  has_attached_file :song_image, :styles => { :small => "150x150>" },
    :url  => "/assets/songs/images/:id/:style/:basename.:extension",
    :path => ":rails_root/public/assets/songs/images/:id/:style/:basename.:extension"

  has_attached_file :song_file, :styles => { :small => "150x150>" },
    :url  => "/assets/songs/file/:id/:style/:basename.:extension",
    :path => ":rails_root/public/assets/songs/file/:id/:style/:basename.:extension", :whiny=> false

  #validates_attachment_presence :song_image
  #validates_attachment_presence :song_file
  # validates_attachment_size :song_file, :less_than => 10.megabytes,
  #   :message => 'filesize must be less than 10 MegaBytes'

   validates_attachment_content_type :song_image, :content_type => ['image/jpeg', 'image/png'], :message => 'file must be of filetype .jpeg or .png'
  #do_not_validate_attachment_file_type :song_file
    validates_attachment_content_type :song_file, :content_type => [ 'application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3' ] ,
      :message => 'file must be of filetype .mp3'


  #--
  # Created By: Chaitali khangar
  # Created On: 19/05/2013
  # Purpose: To set mime type
  #++
  def set_mime_type(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s
    self.song_file = data
  end


  #--
  # Created By: Chaitali khangar
  # Created On: 19/05/2013
  # Purpose: To set default played song value
  #++

  def set_default_played_song
    self.played_song = 0
  end
   
end
