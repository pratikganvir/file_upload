class PagesController < ApplicationController
  def terms
  end

  def welcome
  end

  def landing
    redirect_to "/add_email?id=#{current_user.id}" and return if current_user && ! current_user.email?
  end
end
