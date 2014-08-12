class BlogController < ApplicationController
  before_action :set_post, only: [:show]

  private
  
  def set_post
    @post = Post.find(params[:id])
  end
end
