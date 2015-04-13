class NewsArticle < ActiveRecord::Base
  acts_as_routable \
    title_field: :caption, 
    name_field: :slug
end
