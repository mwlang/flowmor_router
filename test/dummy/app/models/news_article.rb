class NewsArticle < ActiveRecord::Base
  acts_as_flowmor_routable \
    derived_name_field: :caption, 
    name_field: :slug
end
