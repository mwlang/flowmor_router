class Article < RoutableRecord
  scope :routable, -> { where(published: true) }
end
