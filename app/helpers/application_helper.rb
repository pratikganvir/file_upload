module ApplicationHelper

  def current_user_age_range(current_user)
    current_user.age_range
  end

end
