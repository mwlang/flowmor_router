require 'test_helper'

class NewsArticleTest < ActiveSupport::TestCase
  test "news_article#controller_action" do
    assert_equal "news_article#show", NewsArticle.new.controller_action
  end
  
  test "news_article#route_name" do 
    assert_equal 'news_articles_dummy_news_article', NewsArticle.new(caption: "Dummy News Article").route_name
  end
  
  test "news_article#route_name_prefix" do
    assert_equal 'news_articles', NewsArticle.new(caption: "Dummy News Article").route_name_prefix
  end

  test "news_article#derived_name_field_value" do 
    assert_equal 'Dummy News Article', NewsArticle.new(caption: "Dummy News Article").derived_name_field_value
  end
  
  test "news_article#new_name_value" do 
    assert_equal 'dummy-news-article', NewsArticle.new(caption: "Dummy News Article").new_name_value
  end

  test "news_article#slug" do 
    assert_equal 'dummy-news-article', NewsArticle.create(caption: "Dummy News Article").slug
  end
  
  test "NewsArticle#route_model" do 
    assert_equal 'news_article', NewsArticle.route_model
  end
  
  test "news_article#path" do
    assert_raise FlowmorRouter::UnroutableRecord do
      NewsArticle.new(caption: nil).path
    end
    assert_raise FlowmorRouter::UnroutableRecord do
      NewsArticle.create(caption: nil).path
    end
    assert_equal '/news-articles/dummy-news-article', NewsArticle.create(caption: "Dummy News Article").path
  end
  
  test "news_article#url" do 
    assert_raise FlowmorRouter::UnroutableRecord do
      NewsArticle.new(caption: nil).url
    end
    assert_raise FlowmorRouter::UnroutableRecord do
      NewsArticle.create(caption: nil).url
    end
  end
end
