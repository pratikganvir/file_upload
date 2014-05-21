# == Schema Information
#
# Table name: genres
#
#  id         :integer          not null, primary key
#  song_type  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :genre do
    song_type "MyString"
  end
end
