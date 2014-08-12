class RoutableRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.route_model
    name.underscore.downcase
  end

  def route_model
    self.class.route_model
  end
  
  def self.set_controller_action value
    @controller_action = value
  end

  def self.default_controller_action
    "#{route_model.underscore}#show"
  end

  def self.controller_action
    @controller_action || default_controller_action
  end
  
  def controller_action
    self.class.controller_action
  end
  
  def self.set_derived_name_field value
    @derived_name_field = value
  end

  def self.derived_name_field
    @derived_name_field || 'title'
  end
  
  def derived_name_field
    self.class.derived_name_field
  end

  def derived_name_field_value
    if respond_to? derived_name_field
      send(derived_name_field)
    else
      raise RuntimeError
    end
  end

  def self.set_name_field value
    @name_field = value
  end
  
  def self.name_field
    @name_field || 'name'
  end
  
  def name_field
    self.class.name_field
  end

  def name_field_value
    attributes[name_field]
  end

  include Rails.application.routes.url_helpers

  after_save :reload_routes
  before_save :populate_name

  def route_name_prefix
    "#{route_model.pluralize}"
  end
  
  def route_name
    name_suffix = new_name_value
    raise UnroutableRecord if name_suffix.blank?
    
    "#{route_name_prefix}_#{name_suffix}".underscore
  end

  def route_prefix
    "/#{route_model.pluralize.gsub('_', '-')}"
  end
  
  def route
    "#{route_prefix}/#{new_name_value}"
  end
  
  def default_url_options
    { :host => Thread.current[:host], :port => Thread.current[:port] }
  end
  
  def url
    send("#{route_name}_url", default_url_options)
  end

  def path
    send("#{route_name}_path")
  end
  
  def new_name_value
    if value = derived_name_field_value and !value.blank?
      value.downcase.gsub(/[^\w\s\d\_\-]/,'').gsub(/\s\s+/,' ').gsub(/[^\w\d]/, '-')
    else
      raise FlowmorRouter::UnroutableRecord if value.blank?
    end
  end
  
  def name_field_changed?
    new_name_value != attributes[name_field]
  end
  
  def populate_name
    if attributes[name_field].blank? || name_field_changed?
      send("#{name_field}=", new_name_value)
    end
  end
  
  def reload_routes
    Rails.application.routes_reloader.reload!
  end
end
