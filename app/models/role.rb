# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  role_name  :string(255)      default("User")
#  created_at :datetime
#  updated_at :datetime
#

class Role < ActiveRecord::Base
  
  belongs_to :user

  ROLES = %w{"Admin","User"}
  
end
