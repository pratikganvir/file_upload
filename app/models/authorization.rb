# == Schema Information
#
# Table name: authorizations
#
#  id         :integer          not null, primary key
#  provider   :string(255)
#  uid        :string(255)
#  user_id    :integer
#  token      :string(255)
#  secret     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Authorization < ActiveRecord::Base
	belongs_to :user

	after_create :fetch_details

  validates_uniqueness_of :uid ,:message => "Please sign in with other account. This account belongs to other user."

  #--
  # Created By: Chaitali Khangar
  # Created On: 24/04/2014
  # Purpose: To fetch details from provider
  #++

	def fetch_details
		self.send("fetch_details_from_#{self.provider.downcase}")
	end



  #--
  # Created By: Chaitali Khangar
  # Created On: 24/04/2014
  # Purpose: To fetch details from facebook
  #++

	def fetch_details_from_facebook
		graph = Koala::Facebook::API.new(self.token)
		facebook_data = graph.get_object("me")
		self.save
	end


  #--
  # Created By: Chaitali Khangar
  # Created On: 24/04/2014
  # Purpose: To fetch details from twitter
  #++
	def fetch_details_from_twitter

	end

end
