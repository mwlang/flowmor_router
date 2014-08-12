require 'test_helper'

class RoutableRecordsTest < ActionDispatch::IntegrationTest
  test "/general/lets-test-this" do
    post = Post.create(title: "Let's Test This")
    assert_equal post.name, 'lets-test-this'
    assert_equal "/general/lets-test-this", post.path
    get post.path
    assert_response :success
    assert_select "h1", "Let&#39;s Test This"
  end
end
