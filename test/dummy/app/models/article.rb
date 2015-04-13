class Article < ActiveRecord::Base
  acts_as_routable \
    scope: -> { where(published: true) },
    name: :custom_name
    
  def custom_name
    self.title.try(:parameterize) || self.id
  end
end
