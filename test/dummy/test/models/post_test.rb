require 'test_helper'

class PostTest < ActiveSupport::TestCase
  setup do
    @category = PostCategory.create(name: "general")
    @post = Post.create(title: "Once Upon a Time")
  end
  
  test "post#route_name" do 
    assert_equal 'by_category_posts_general_once_upon_a_time', @post.route_name
  end
  
  test "Post controller_action" do 
    assert_equal 'blog#show', Post.flowmor_posts_router_class.controller_action
  end

  test "post#path" do
    assert_equal '/by_category/posts/general/once-upon-a-time', @post.path
  end

  test "post#archive_path" do
    assert_equal '/archive/once-upon-a-time', @post.archive_path
  end
end
