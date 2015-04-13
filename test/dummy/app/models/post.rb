class Post < ActiveRecord::Base
  belongs_to :category, class_name: "PostCategory", counter_cache: true

  before_save :populate_name
  
  def populate_name
    self.name = self.title.to_s.downcase.gsub(/[^\w\s\d\_\-]/,'').gsub(/\s\s+/,' ').gsub(/[^\w\d]/, '-')
  end
  
  acts_as_routable \
    controller_action: "blog#show",
    prefix: :by_category,
    suffix: -> { :category_name }

  acts_as_routable :archive
    
  def category_name
    self.category.try(:name) || 'general'
  end
end
