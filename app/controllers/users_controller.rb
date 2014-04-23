class UsersController < ApplicationController
  before_filter :set_user, :only=> [:show, :edit, :update,:add_email]
  before_filter :validate_authorization_for_user, :only=> [:edit, :update]



  def show
    redirect_to "/add_email?id=#{current_user.id}" and return unless @user.email?
  end


  def edit
  end

  def add_email
  end

  #--
  # Created By: Chaitali khangar
  # Purpose: To save email
  # Created On: 23/04/2014
  #++
  def save_email
    @user = User.find(params[:user][:id])
    if @user.update_attributes(:email=>params[:user][:email])
      redirect_to root_url, :notice=> 'User email was successfully updated.'
    else
      flash[:error] = @user.errors.full_messages.uniq.join("\n")
      render :action=> 'add_email',:id=>@user.id   
    end
  end


  def update
    if @user.update_attributes(user_params)
      redirect_to @user, :notice=> 'User was successfully updated.'
    else
      render 'edit'
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def validate_authorization_for_user
    redirect_to root_path unless @user == current_user
  end

  def user_params
    params.require(:user).permit(:name, :age_range)
  end
end
