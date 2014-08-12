require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test "post#controller_action" do
    assert_equal "blog#show", Post.new.controller_action
  end
  
  test "default category is 'general'" do 
    assert_equal 'general', Post.new.category_name
  end
  
  test "post#route_name" do 
    assert_equal 'posts_general_dummy_post', Post.new(title: "Dummy Post").route_name
  end
  
  test "post#route_name_prefix" do
    assert_equal 'posts_general', Post.new(title: "Dummy Post").route_name_prefix
  end

  test "post#derived_name_field_value" do 
    assert_equal 'Dummy Post', Post.new(title: "Dummy Post").derived_name_field_value
  end
  
  test "post#new_name_value" do 
    assert_equal 'dummy-post', Post.new(title: "Dummy Post").new_name_value
  end
  
  test "Post#route_model" do 
    assert_equal 'post', Post.route_model
  end
  
  test "post#path" do
    assert_raise FlowmorRouter::UnroutableRecord do
      Post.new(title: nil).path
    end
    assert_raise FlowmorRouter::UnroutableRecord do
      Post.create(title: nil).path
    end
    assert_equal '/general/dummy-post', Post.create(title: "Dummy Post").path
  end
  
  test "post#url" do 
    assert_raise FlowmorRouter::UnroutableRecord do
      Post.new(title: nil).url
    end
    assert_raise FlowmorRouter::UnroutableRecord do
      Post.create(title: nil).url
    end
  end
end
