class PostCategory < RoutableRecord
  has_many :posts, foreign_key: "category_id"

  set_controller_action "blog#category"

  def route_model
    "category"
  end
end
