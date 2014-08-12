class NewsArticle < RoutableRecord
  set_derived_name_field :caption
  set_name_field  :slug
end
