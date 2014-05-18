class OmniauthCallbacksController < Devise::OmniauthCallbacksController

	skip_before_filter :authenticate_user!
	def all
		p env["omniauth.auth"]
		authorization = User.from_omniauth(env["omniauth.auth"], current_user)
    if authorization == User::EXISTING_ACCOUNT
      flash[:error] = authorization
      redirect_to(:controller=> "users",:action=>"edit" , :id=>current_user.id) and return
    elsif authorization.errors.present?
      flash[:error] = authorization.errors.full_messages.first.gsub("Uid ","")
      redirect_to(:controller=> "users",:action=>"edit" , :id=>current_user.id) and return
    end
    user = authorization.user
		if user.persisted?
			flash[:notice] = 'Sign in succefully! Click on your name to see the status for the accounts'
			sign_in_and_redirect(user)
		else
			session["devise.user_attributes"] = user.attributes
			redirect_to new_user_registration_url
		end
	end

  def failure
    #handle you logic here..
    #and delegate to super.
    super
  end


	alias_method :facebook, :all
	alias_method :twitter, :all
  #	alias_method :linkedin, :all
  #	alias_method :github, :all
  #	alias_method :passthru, :all
  #	alias_method :google_oauth2, :all
end
