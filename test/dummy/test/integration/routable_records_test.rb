require 'test_helper'

class RoutableRecordsTest < ActionDispatch::IntegrationTest
  test "/general/lets-test-this" do
    post = Post.create(title: "Let's Test This")
    assert_equal post.name, 'lets-test-this'
    assert_equal "/general/lets-test-this", post.path
    get post.path
    assert_response :success
    assert_select "h1", "Let's Test This"
  end
  
  test "only routable routes built" do 
    a1 = Article.create(title: "Route This", published: true)
    a2 = Article.create(title: "Ignore This", published: false)
    get a1.path
    assert_response :success
    assert_raise FlowmorRouter::UnroutedRecord do
      get a2.path
    end
    assert_raise ActionController::RoutingError do
      get '/articles/ignore-this'
    end
  end

  test "two words" do 
    get static_two_words_path
    assert_response :success
    assert_select "h1", "Two Words"
  end
  
end
