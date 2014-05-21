#require 'mime/types'

class Song < ActiveRecord::Base
  has_attached_file :song_image, :styles => { :small => "150x150>" },
    :url  => "/assets/songs/images/:id/:style/:basename.:extension",
    :path => ":rails_root/public/assets/songs/images/:id/:style/:basename.:extension"

  has_attached_file :song_file, :styles => { :small => "150x150>" },
    :url  => "/assets/songs/file/:id/:style/:basename.:extension",
    :path => ":rails_root/public/assets/songs/file/:id/:style/:basename.:extension", :whiny=> false

  validates_attachment_presence :song_image
  validates_attachment_presence :song_file
  validates_attachment_size :song_file, :less_than => 10.megabytes,
    :message => 'filesize must be less than 10 MegaBytes'

  validates_attachment_content_type :song_image, :content_type => ['image/jpeg', 'image/png'], :message => 'file must be of filetype .jpeg or .png'
  #do_not_validate_attachment_file_type :song_file
  validates_attachment_content_type :song_file, :content_type => [ 'application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3' ] ,
    :message => 'file must be of filetype .mp3'


  validates_presence_of :artist_name,:title,:duration,:price
  
  validate :artist_name_valid_format
  validate :title_valid_format
 
  validate :duration_format
  validate :price_format
  belongs_to :genre



  #--
  # Created By: Chaitali khangar
  # Created On: 21/05/2013
  # Purpose: To validate artist name format
  #++
  def artist_name_valid_format
    if artist_name.present? and not artist_name.match(/^(?:[^\W_]|\s)*$/)
      errors.add :artist_name , "must not contain any special characters."
    end
  end

  #--
  # Created By: Chaitali khangar
  # Created On: 21/05/2013
  # Purpose: To validate title format
  #++
  def title_valid_format
    if title.present? and not title.match(/^(?:[^\W_]|\s)*$/)
      errors.add :title , "must not contain any special characters."
    end
  end


  #--
  # Created By: Chaitali khangar
  # Created On: 21/05/2013
  # Purpose: To validate duration format
  #++
  def duration_format
    if duration.present?
      begin
        Float(duration)
      rescue
        errors.add :duration , "must be numeric value."
      end
    end
  end


  #--
  # Created By: Chaitali khangar
  # Created On: 21/05/2013
  # Purpose: To validate price format
  #++
  def price_format
    if price.present?
      begin
        Float(price)
      rescue
        errors.add :price , "must be numeric value."
      end
    end
  end

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


  #--
  # Created By: Chaitali khangar
  # Created On: 21/05/2013
  # Purpose: To cut song for 30 seconds
  #++
  def self.cut_song_to_30_sec(input_file,file_name)
    output_folder = "#{Rails.root}/public/assets/songs/cut_songs/"
    FileUtils.mkdir_p(output_folder) unless File.directory?(output_folder)
    output_folder = "public/assets/songs/cut_songs/"
    if file_name.present?
      output_file = "#{output_folder}#{file_name}"
      begin
        system("ffmpeg -t 30 -i #{input_file}  #{output_file} ")
      rescue Exception => e
        puts "******************#{e}***************"
      end
    end
  end
end
