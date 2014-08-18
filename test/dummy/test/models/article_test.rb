require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test "article#controller_action" do
    assert Article.new.controller_action, "article#show"
  end
  
  test "article#route_name" do 
    assert Article.new(title: "Dummy Article").route_name, 'articles_dummy_article'
  end
  
  test "article#route_name_prefix" do
    assert Article.new(title: "Dummy Article").route_name_prefix, 'article'
  end

  test "article#derived_name_field_value" do 
    assert Article.new(title: "Dummy Article").derived_name_field_value, 'dummy-article'
  end
  
  test "article#path" do
    assert_raise FlowmorRouter::UnroutableRecord do
      Article.new(title: nil).path
    end
    assert_raise FlowmorRouter::UnroutableRecord do
      Article.create(title: nil).path
    end
    assert_raise FlowmorRouter::UnroutedRecord do
      assert Article.create(title: "Dummy Article").path, '/articles/dummy-article'
    end
  end
end
