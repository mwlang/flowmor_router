require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_select "h1", "Static Page Example"
    assert_select "p", "It Works!"
  end
end
