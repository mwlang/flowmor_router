class PostCategory < ActiveRecord::Base
  has_many :posts, foreign_key: "category_id"

  acts_as_flowmor_routable \
    controller_action: "blog#category",
    route_model: "category"
end
