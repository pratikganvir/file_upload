class Api::V1::RegistrationsController < Devise::RegistrationsController

  skip_before_filter :verify_authenticity_token


  ERROR_MESSAGE_FOR_PASSWORD = 'This password is same as your previous password. Please update other password'


	#++
  # Created By: Chaitali Khangar
	# Purpose:- User for edit user details
	# Created On: 5/05/2014
	#--
  def edit
    if request.format.html? && current_user.email.blank?
      flash[:alert] = "Please add email address first"
      redirect_to :back and return
    end
    super
  end


  #++
  # Created By: Chaitali Khangar
	# Purpose:- User sign up
	# Usage:- #http://127.0.0.1:3000/api/v1/users?user[email]=sample@c.com&user[password]=Chaitali1&user[password_confirmation]=Chaitali1&user[name]=chaitali khangar&user[age_range]=Below18
	# Type:- POST
  # Created On: 5/05/2014
	#--
	def create

    (super and return)  if request.format.html?
	  user = User.new(allow_registration_parameters)
	  if user.save
	    render :status => 201, :json => {:user => user , :token => user.authentication_token }
	    return
	  else
	    warden.custom_failure!
      errors = user.errors.full_messages.join("<br/>").html_safe
	    render :json=> {:status=>422,:message => errors}
	  end
	end

	#++
  # Created By: Chaitali Khangar
	# Purpose:- User sign up
	# Usage:- #127.0.0.1:3000/api/v1/edit?token=1gjMKdwWHfQy9zyd2zE22RaW9TAd5ZGpXQ&user[age_range]=19-24&user[current_password]=Chaitali1&user[password]=Chaitali123&user[password_confirmation]=Chaitali123&user[name]=Chaitali Khangar
	# Type:- POST
  # Created On: 5/05/2014
	#--
  def update
    if request.format.html? && params["user"]["password"].present? &&
        params["user"]["password"] == params["user"]["password_confirmation"] &&
        params["user"]["password"] == params["user"]["current_password"]
      flash[:alert] = ERROR_MESSAGE_FOR_PASSWORD
      redirect_to  edit_user_registration_path and return
    elsif request.format.html?
      super
    else
      @user = User.find_by_authentication_token(params[:token])
      if !params[:user].nil? && !@user.blank?
        if params["user"]["password"].present? &&
            params["user"]["password"] == params["user"]["password_confirmation"] &&
            params["user"]["password"] == params["user"]["current_password"]
          render :status => 404, :json => {:message => ERROR_MESSAGE_FOR_PASSWORD} and return
        end
        if @user.valid_password?(params[:user][:current_password])
          @user.update_attributes(allow_registration_parameters) ? (render :status => 200, :json => {:user => @user, :message => "User details updated."}) :
            (render :status => 404, :json => {:message => @user.errors.full_messages.join("<br/>").html_safe})      
          return
        else
          render :status => 404, :json => {:message => "Current password entered is wrong."}
        end
      else
        render :status => 404, :json => {:message => "Invalid authentication token used."}
      end

    end

  end

  protected
  def authenticate_scope!
    super if request.format.html?
    user =User.find_by_authentication_token(params[:token])
    user.present?
  end

  private

  def allow_registration_parameters
    params.require(:user).permit(:name, :email, :password, :password_confirmation,:age_range)
  end


end


