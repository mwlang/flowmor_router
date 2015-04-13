require 'test_helper'

class NewsArticleTest < ActiveSupport::TestCase
  test "news_article#route_name" do 
    assert_equal 'news_articles_dummy_news_article', NewsArticle.new(caption: "Dummy News Article").route_name
  end
  
  test "NewsArticle controller_action" do 
    assert_equal 'news_article#show', NewsArticle.flowmor_news_articles_router_class.controller_action
  end

  test "news_article#path" do
    assert_raise FlowmorRouter::UnroutableRecord do
      NewsArticle.new(caption: nil).path
    end
    assert_raise FlowmorRouter::UnroutableRecord do
      NewsArticle.create(caption: nil).path
    end
    real_article = NewsArticle.create(caption: "Real News Article")
    assert_equal '/news_articles/real-news-article', Rails.application.routes.url_helpers.news_articles_real_news_article_path
    assert_equal '/news_articles/real-news-article', real_article.path
  end
  
  test "news_article#url" do 
    assert_raise FlowmorRouter::UnroutableRecord do
      NewsArticle.new(caption: nil).url
    end
    assert_raise FlowmorRouter::UnroutableRecord do
      NewsArticle.create(caption: nil).url
    end

    real_article = NewsArticle.create(caption: "Real News Article")
    Thread.current[:host] = "localhost"
    Thread.current[:port] = "3000"
    assert_equal 'http://localhost:3000/news_articles/real-news-article', real_article.url
  end
end
