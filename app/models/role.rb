class Role < ActiveRecord::Base
  
  belongs_to :user

  ROLES = %w{"Admin","User"}
  
end
