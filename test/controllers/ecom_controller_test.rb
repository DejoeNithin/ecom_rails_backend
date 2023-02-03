require 'test_helper'

class EcomControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ecom_index_url
    assert_response :success
  end

end
