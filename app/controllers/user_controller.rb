class UserController < ApplicationController
  protect_from_forgery
  before_action :validate_auth_token, except: [:new, :create]
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(valid_params)
    @token = Token.new(:user_id => @user.id, :token => nil, :refresh_time => nil, :expiry_time => nil)
    
    if @user.save && @token.save
      render json: @user 
    else 
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
  def valid_params
    params.require(:user).permit(:name, :email, :password)
  end 
end
