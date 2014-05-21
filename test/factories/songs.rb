# == Schema Information
#
# Table name: songs
#
#  id                      :integer          not null, primary key
#  artist_name             :string(255)
#  title                   :string(255)
#  duration                :string(255)
#  price                   :float
#  played_song             :integer
#  country                 :string(255)
#  song_image              :string(255)
#  song_file               :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  song_image_file_name    :string(255)
#  song_image_content_type :string(255)
#  song_image_file_size    :integer
#  song_image_updated_at   :datetime
#  song_file_file_name     :string(255)
#  song_file_content_type  :string(255)
#  song_file_file_size     :integer
#  song_file_updated_at    :datetime
#  genre_id                :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :song do
    artist_name "MyString"
    title "MyString"
    genere_name "MyString"
    duration "MyString"
    price 1.5
    played_song 1
    country "MyString"
    song_image "MyString"
    song_file "MyString"
  end
end
