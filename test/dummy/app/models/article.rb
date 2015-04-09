class Article < ActiveRecord::Base
  acts_as_routable scope: -> { where(published: true) }
end
