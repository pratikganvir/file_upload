class Api::V1::SessionsController < Devise::SessionsController  
  skip_before_filter :authenticate_user!   
  skip_before_filter :verify_authenticity_token
  before_filter :devise_authenticates!, :only =>[:all_users,:date_today]


  #--
  # Created By: Chaitali Khangar
  # Purpose: To override the devise method for handling already sign in json response.
  # Created On: 5/05/2014
  #++
  def require_no_authentication
    assert_is_devise_resource!
    return unless is_navigational_format?
    no_input = devise_mapping.no_input_strategies

    authenticated = if no_input.present?
      args = no_input.dup.push scope: resource_name
      warden.authenticate?(*args)
    else
      warden.authenticated?(resource_name)
    end

    if authenticated && resource = warden.user(resource_name)
      if request.format.html?
        flash[:alert] = I18n.t("devise.failure.already_authenticated")
        redirect_to after_sign_in_path_for(resource)
      else
        render :status => 200, :json => {:user => resource , :token => resource.authentication_token , :message => I18n.t("devise.failure.already_authenticated")}
      end
    end
  end



  #++
  # Created By: Chaitali Khangar
  # Purpose:- Authenticate the authentication key provided with the URL.
  # Created On: 5/5/2014
  #--
  def devise_authenticates!
    user = User.find_by_authentication_token(params[:token])
    render :json=>{:message=>"Unauthorized", :status=>401 } unless user    
  end

  #++
  # Created By: Chaitali Khangar
  # 25 Nov, 2013
  # Purpose:- Sign in with valid credentials and return authentication key as response.
  # Usage:- 127.0.0.1:3000/api/v1/sessions?user[email]=a@c.com&user[password]=testcipher 
  # Type:- POST
  # Created On: 5/5/2014
  #--
  def create
    super and return if request.format.html?
    email = params[:user][:email]       
    password = params[:user][:password]
    if email.nil? or password.nil?
      render :json=>{:status => 400, :message => "The request must contain the user email and password."}
      return
    end
    @user = User.find_by_email(email.downcase)
    if @user.nil?
      render :json=>{:status => 401, :message => "Invalid email or password."}
      return
    end
    authenticate_user_from_token!
    if not @user.valid_password?(password)
      render :json=>{:status => 401, :message => "Invalid email or password."}
    else
      render :json=>{:status => 200, :user => @user , :token => @user.authentication_token , :message => "Successfully signed in."}
    end    
  end


  # Purpose:- Update the user profile with current password only.
  # Usage:- 127.0.0.1:3000/api/v1/sessions/xNhHzjAxqX5jbSGoC-yB
  # user[email] = c@c.com
  # user[name] = fname lname
  # user[current_password] = testcipher123 <-- IMP

  # if desired a new password
  # user[password] = testcipher123
  # user[password_confirmation] = testcipher123
  # Type:- PUT
  #--
  def update
    #check gymid provided matches with the system
    #check if new password and confirmation are both provided
    if params[:user][:password] && params[:user][:password_confirmation].blank?
      render :status => 404, :json => {:message => "Please confirm password."}
      return
    end
    @user = User.find_by_authentication_token(params[:id])
    if !params[:user].nil? && !@user.blank?
      if @user.valid_password?(params[:user][:current_password])
        @user.update_with_password(params[:user])
        if @user.errors.messages.blank?
          render :json=>{:status => 200, :user => @user, :message => "User details updated."}
        else
          render :json=>{:status => 404, :message => "#{@user.errors.messages.keys[0]} #{@user.errors.messages.values[0][0]}"}
        end
        return
      else
        render :json=>{:status => 404, :message => "Current password entered is wrong."}
      end
    else
      render :json=>{:status => 404, :message => "Invalid authentication token used."}
    end
  end

  #++
  # Created By: Chaitali Khangar
  # Purpose:- Method to find current user with authentication token
  # Usage:- 127.0.0.1:3000/api/v1/api_current_user/DMiTxGiRgBsNTj39Hnr2    
  # Type:- GET
  # Created On: 5/5/2014
  #--
  def api_current_user
    user = User.where("authentication_token=?",params[:id])
    (user && user.first) ? (render :json => user.first) :
      (render :status => 404, :json => {:message => "No current user with this token"})
  end


  #++
  # Created By: Chaitali Khangar
  # Purpose:- Method to sign out current user.
  # Usage:- 127.0.0.1:3000/api/v1/sessions/ACexDqWz8jtydcRMEzvZ
  # Type:- DELETE
  # Created On: 5/5/2014
  #--
  def destroy
    if request.format.html? && current_user.email.blank?
      flash[:alert] = "Please add email address first"
      redirect_to :back and return
    end
    debugger
    super and return if request.format.html?
    @user = User.find_by_authentication_token(params[:id])
    if @user.nil?
      render :json=>{:status => 404, :message => "Invalid token."}
    else
      @user.reset_authentication_token!
      render :json=>{:status => 200, :user=> @user, :old_token => params[:id], :token => @user.authentication_token, :message=>"You are sign out successfully."}
    end
  end

  #++
  # Created By: Chaitali Khangar
  # Purpose:- Method to return todays date as per time zone
  # Usage:- 127.0.0.1:3000/api/v1/date_today?token=psGYx7X8QfKdiM3MktdA
  # Type:- GET
  #   # Created On: 5/5/2014
  #--
  def date_today
    render :json=>{:date_today =>Time.now.in_time_zone.strftime('%Y-%m-%d')}
  end

  #++
  # Bidyut Nath
  # 25 April, 2014
  # Purpose:- Method to reset password
  # Usage:- 127.0.0.1:3000/api/v1/reset_password?email=a@c.com
  #token=zDYcPDVzgP_zL6nbUfAb&user[gymid]=0000&user[current_password]=testcipher
  # Type:- POST
  #--
  def reset_password
    super and return if request.format.html?
    user = User.find_by_email(params[:email])  
    if !user.blank?
      temporary_password = user.generate_password
      user.password =  temporary_password
      user.password_confirmation = temporary_password
      if user.save
        UserMailer.reset_password_mail_by_api(user,temporary_password).deliver
        render :json => {:status => 200,:message => "New password is sent to your email address."}
      else
        render :json => {:status => 404,:message => user.errors.full_message}
      end
    else
      render :json => {:status => 401,:message => "Account with provided email address not found."}
    end    
  end



  private

  #--
  # Created By: Chaitali Khangar
  # Purpose: To override the authentication from token method
  # Created On: 5/05/2014
  #++

  def authenticate_user_from_token!
    user_email = params[:user_email].presence
    user = user_email && User.find_by_email(user_email)
    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      sign_in user, store: false
    end
  end
end



