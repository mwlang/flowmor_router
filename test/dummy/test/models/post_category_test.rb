require 'test_helper'

class PostCategoryCategoryTest < ActiveSupport::TestCase
  test "post_category#route_name" do 
    assert_equal 'category_general', PostCategory.new(name: "general").route_name
  end
  
  test "PostCategory controller_action" do 
    assert_equal 'blog#category', PostCategory.flowmor_category_router_class.controller_action
  end

  test "post_category#path" do
    assert_raise FlowmorRouter::UnroutableRecord do
      PostCategory.new(title: nil).path
    end
    assert_raise FlowmorRouter::UnroutableRecord do
      PostCategory.create(title: nil).path
    end
    assert_equal '/category/general', PostCategory.create(title: "General").path
  end
end
