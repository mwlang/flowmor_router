class PostCategory < ActiveRecord::Base
  has_many :posts, foreign_key: "category_id"

  acts_as_routable \
    :category,
    controller_action: "blog#category"
end
