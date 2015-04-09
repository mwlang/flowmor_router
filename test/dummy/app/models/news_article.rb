class NewsArticle < ActiveRecord::Base
  acts_as_routable \
    derived_name_field: :caption, 
    name_field: :slug
end
