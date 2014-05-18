class Api::V1::BaseController < ApplicationController	
  before_filter :devise_authenticates!
  before_filter :verify_authenticity_token


  def devise_authenticates!
    user = User.find_by_authentication_token(params[:auth_token])
    render :json=>{:message=>"Unauthorized", :status=>401 } unless user
  end

  respond_to :json

end
