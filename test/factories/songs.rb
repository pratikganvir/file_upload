# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :song do
    artist_name "MyString"
    title "MyString"
    genere_name "MyString"
    duration "2014-04-24 12:49:45"
    price 1.5
    played_song 1
    country "MyString"
  end
end
