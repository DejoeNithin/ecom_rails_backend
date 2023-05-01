class SessionController < ApplicationController
  protect_from_forgery
  before_action :validate_auth_token, except: [:new, :create]
  
  def new
    @user = User.new
  end

  def create
    @user = User.find_by(email: params[:email])
    p "user : #{@user}"
    
    if @user && @user.password == user_params[:password]
      #@tok.token = Base64.encode64(Time.now.to_s + @user.email)
      #using the combination of (user_id + datetime.now + email) to generate new token
      Token.where(:user_id => @user.id).update_all(token: Base64.encode64(@user.id.to_s + " " + Time.now.to_s + @user.email).chop)
      Token.where(:user_id => @user.id).update_all(refresh_time: DateTime.now)
      #expiry time = current time + 60minutes
      Token.where(:user_id => @user.id).update_all(expiry_time: DateTime.now + 60.minutes)
      
      #response.headers["email"] = @user.email
      @tok = Token.find_by_user_id(@user.id)
      #set token in response header
      response.headers["token"] = @tok.token
      render :json => @tok.as_json.merge(:email => @user.email)
    else
      render json: @user.errors, status: :unprocessable_entity
    end 
  end

  def destroy
    @user_id = get_id_from_token
    Token.where(:user_id => @user_id).update_all(token: nil)
    Token.where(:user_id => @user_id).update_all(refresh_time: nil)
    Token.where(:user_id => @user_id).update_all(expiry_time: nil)
    @user = User.find_by(:id => @user_id)
    render :json => {"message" => " User #{@user.name} logged out!!!"}
  end

  private
  def user_params
    params.require(:session).permit(:email, :password)
  end
end
