require 'test_helper'

class PostCategoryCategoryTest < ActiveSupport::TestCase
  test "post_category#controller_action" do
    assert_equal "blog#category", PostCategory.new.controller_action
  end
  
  test "post_category#route_name" do 
    assert_equal 'categories_general', PostCategory.new(title: "General").route_name
  end
  
  test "post_category#route_name_prefix" do
    assert_equal 'categories', PostCategory.new(title: "General").route_name_prefix
  end

  test "post_category#derived_name_field_value" do 
    assert_equal 'General', PostCategory.new(title: "General").derived_name_field_value
  end
  
  test "post_category#new_name_value" do 
    assert_equal 'general', PostCategory.new(title: "General").new_name_value
  end
  
  test "PostCategory#route_model" do 
    assert_equal 'category', PostCategory.route_model
  end
  
  test "post_category#path" do
    assert_raise FlowmorRouter::UnroutableRecord do
      PostCategory.new(title: nil).path
    end
    assert_raise FlowmorRouter::UnroutableRecord do
      PostCategory.create(title: nil).path
    end
    assert_equal '/categories/general', PostCategory.create(title: "General").path
  end
  
  test "post_category#url" do 
    assert_raise FlowmorRouter::UnroutableRecord do
      PostCategory.new(title: nil).url
    end
    assert_raise FlowmorRouter::UnroutableRecord do
      PostCategory.create(title: nil).url
    end
  end
end
