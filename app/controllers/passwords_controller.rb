class PasswordsController < Devise::PasswordsController
  skip_before_filter :verify_authenticity_token, :only => [:index, :show]

  #--
  # Created By: Chiatli Khangar
  # Created On: 23/04/2014
  # Purpose: To redirect user if password token already used.
  #++

  def edit
    self.resource = resource_class.find_or_initialize_with_error_by(:reset_password_token, params[:reset_password_token])
    if !resource.errors.empty?
      flash[:alert] = "Password token is invalid"
      redirect_to new_session_path(resource_name)
    end
  end

  #--
  # Created By: Chiatli Khangar
  # Created On: 23/04/2014
  # Purpose: To reset password
  #++
  def update
    self.resource = resource_class.find_or_initialize_with_error_by(:reset_password_token, params[:user][:reset_password_token])
    if !resource.errors.empty?
      flash[:alert] = "Password token is invalid"
      redirect_to new_session_path(resource_name)
    else
      self.resource.password = resource_params[:password]
      self.resource.password_confirmation = resource_params[:password_confirmation]

      if self.resource.valid?
        self.resource.reset_password_token = nil
        self.resource.reset_password_sent_at = nil
      end
      
      if self.resource.save
        flash[:notice] = "Password reset successfully."
        redirect_to new_session_path(resource_name)
      else
        flash[:error] = self.resource.errors.full_messages.uniq.join("<br/>").html_safe
        redirect_to :back
      end
    end
  end

end