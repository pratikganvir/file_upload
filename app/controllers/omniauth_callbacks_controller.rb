class OmniauthCallbacksController < Devise::OmniauthCallbacksController

	skip_before_filter :authenticate_user!
	def all
		p env["omniauth.auth"]
    if request.format.json?
      login_using_api(hash)
    else
      http_login
    end
	end

  def failure
    #handle you logic here..
    #and delegate to super.
    super
  end

  def login_using_api
    hash=OmniAuth::AuthHash.new(:credentials => {:token=>params[:credentials][:token]}, 
          :provider => params[:provider], :uid=> params[:uid], 
          :info => {:name => params[:info][:name],
                    :email => params[:info][:email]}, 
                    :extra => {:raw_info => 
                                 {:birthday => params[:extra][:raw_info][:birthday]}
                              })
    authorization = User.from_omniauth(hash, current_user)
  end

  def http_login
    authorization = User.from_omniauth(env["omniauth.auth"], current_user)
    #check for the errors
    if authorization.errors.present?
      respond_to do |format|
        error = authorization.errors.full_messages.first.gsub("Uid ","")
        format.html do
          flash[:error] = error
          redirect_to(:controller=> "users",:action=>"edit" , :id=>current_user.id) and return
        end

        format.json do
          render :json => {:error => error, :status => 401}
        end
      end
    end

    user = authorization.user
    #If user is first time user
    if user.persisted?
      respond_to do |format|
        message = 'Sign in succefully! Click on your name to see the status for the accounts'
        format.html do
          flash[:notice] = message
          sign_in_and_redirect(user)
        end
        
        format.json do
          render :json => {:user => user, :message => message, :status => 200}
        end
      end

    else
    
      respond_to do |format|
        message = session["devise.user_attributes"] = user.attributes
        format.html do
          redirect_to new_user_registration_url
        end

        format.json do
          render :json => {:user => user, :message => message, :status => 401}
        end
      end

    end

  end

	alias_method :facebook, :all
	alias_method :twitter, :all
  #	alias_method :linkedin, :all
  #	alias_method :github, :all
  #	alias_method :passthru, :all
  #	alias_method :google_oauth2, :all
end
