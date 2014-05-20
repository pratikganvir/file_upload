user = User.new(:name=> 'Admin Admin',:email => 'admin@admin.com', :password => 'Restrict29Pass', :password_confirmation => 'Restrict29Pass',:status=>"Active")
user.build_role(:role_name=>"Admin")
user.skip_confirmation!
user.save
