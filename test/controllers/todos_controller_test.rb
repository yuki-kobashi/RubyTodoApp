require "test_helper"

class TodosControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get index" do
    sign_in users(:one)
    get todos_url
    assert_response :success
  end
end
