class ArticleController < ApplicationController
  before_action :set_article, only: [:show]

  private
  
  def set_article
    @article = Article.find(params[:id])
  end
end
