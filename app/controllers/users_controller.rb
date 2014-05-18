class UsersController < ApplicationController
  before_filter :set_user, :only=> [:show, :edit, :update,:add_email]
  before_filter :validate_authorization_for_user, :only=> [:edit, :update]



  def admin_users
     @users = User.get_admin_user
  end

  def index
    @users = User.get_normal_user
  end

  def show
    redirect_to "/add_email?id=#{current_user.id}" and return unless @user.email?
  end


  def destroy
    @user = User.find(params[:id])
    if @user.update_attributes(:status=>"Inactive")
      flash[:notice] = "User status in inactive."
    end
    redirect_to :back
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
    @user = User.save_email_address(params)
    if @user.save(:validations => {:except => :name})
      redirect_to root_url, :notice=> 'User email was successfully updated.'
    else
      flash[:error] = @user.errors.full_messages.uniq.join("\n")
      render :action=> 'add_email',:id=>@user.id
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
