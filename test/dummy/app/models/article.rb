class Article < ActiveRecord::Base
  acts_as_flowmor_routable scope: -> { where(published: true) }
end
