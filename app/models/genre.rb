# == Schema Information
#
# Table name: genres
#
#  id         :integer          not null, primary key
#  song_type  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Genre < ActiveRecord::Base
  validates_presence_of :song_type
  validate :song_type_valid_format

  has_many :songs ,:dependent=>:destroy


  scope :get_song_type, lambda{|id| where("id=?",id).first}
  
  #--
  # Created By: Chaitali khangar
  # Created On: 21/05/2013
  # Purpose: To validate genre name format
  #++
  def song_type_valid_format
    if song_type.present? and not song_type.match(/^(?:[^\W_]|\s)*$/)
      errors.add :genere_name , "must not contain any special characters."
    end
  end
end
