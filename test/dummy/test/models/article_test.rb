require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  setup do 
    @article = Article.create(title: "Dummy Article", published: true)
  end
  
  test "article#flowmor_article_articles_router_class is a RouterClasses class" do 
    assert @article.flowmor_articles_router_class.is_a?(FlowmorRouter::RouterClasses)
  end

  test "RouterClasses has Article registered" do 
    assert FlowmorRouter::RouterClasses.router_classes.map(&:model).include? Article
  end
  
  test "article#route_name" do 
    assert_equal 'articles_dummy_article', @article.route_name
  end

  test "article#controller_action" do
    assert Article.new.flowmor_articles_router_class.controller_action, "article#show"
  end
  
  test "unpublished articles not routed" do 
    published = Article.create(title: "Published", published: true)
    unpublished = Article.create(title: "Unpublished", published: false)
    assert_equal published.published, true
    assert_equal unpublished.published, false
    assert_equal published.path, '/articles/published'
    assert_raise FlowmorRouter::UnroutedRecord do
      unpublished.path
    end
  end
  
  test "article#path" do
    assert_raise FlowmorRouter::UnroutableRecord do
      Article.new(title: nil).path
    end
    titleless_article = Article.create(title: nil, published: true)
    assert_equal "/articles/#{titleless_article.id}", titleless_article.path
    assert Article.create(title: "Another Article", published: true).path, '/articles/another-article'
  end
end
