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
