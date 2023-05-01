class ApplicationController < ActionController::Base


    private
    # def current_user
    #     if cookies[:email]
    #         User.find_by(email: cookies[:email])
    #     end 
    # end 
    # helper_method :current_user 


    #to execute raw sql statements
    def execute_statement(sql)
        results = ActiveRecord::Base.connection.execute(sql).to_a

        if results.present?
            return results
        else
            return nil
        end
    end
    helper_method :execute_statement 


    #to get product id for the skunit
    def prod(skuv)
        Product.find_by(:id => skuv.product_id)
    end
    helper_method :prod 


    #token validation
    def validate_auth_token
        if request.headers["Authorization"].blank?
            render json: {'status_code': 401, message: '1 - Missing authentication token'}, status: 401 and return
        end 
        
        #puts "author : #{request.headers["Authorization"].size()}".to_s
        @token = Token.find_by(:user_id => get_id_from_token.to_i)
        #puts "#{@token}".to_s 
        if request.headers["Authorization"].to_s != @token.token.to_s
            render json: {'status_code': 401, message: '2 - wrong authentication token'}, status: 401 and return
        end

        @t1=Time.parse(DateTime.now.to_s)
        @t2=Time.parse(@token.expiry_time.to_s)
        if @t1 > @t2
            render json: {'status_code': 401, message: '3 - Token expired!!! Login again'}, status: 401 and return
        end 

    end
    helper_method :validate_auth_token 


    #to parse id from token
    def get_id_from_token
        str = Base64.decode64(request.headers["Authorization"])
        id = ""
        str.each_char { |s|
            break if s == ' '
            id += s 
        }
        return id.to_i
    end 
    helper_method :get_id_from_token 


    def user_params
        params.require(:application).permit(:id)
    end
end
