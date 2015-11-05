module FlowmorRouter
  #
  # class Post < ActiveRecord::Base
  #   acts_as_routable
  # end
  # 
  # route_prefix = ''
  # actor   = posts
  # route_name   = posts_title_me_silly
  # route_path   = posts_title_me_silly_path
  # route_url    = posts_title_me_silly_url
  # @post.path   = /posts/title-me-silly
  # @post.url    = http://example.com/posts/title-me-silly
  #
  #
  # class Post < ActiveRecord::Base
  #   acts_as_routable :ramblings
  # end
  # 
  # route_prefix = ''
  # actor   = ramblings
  # route_name   = ramblings_title_me_silly
  # route_path   = ramblings_title_me_silly_path
  # route_url    = ramblings_title_me_silly_url
  # @post.path   = /ramblings/title-me-silly
  # @post.url    = http://example.com/ramblings/title-me-silly
  #
  # 
  # class Post < ActiveRecord::Base
  #   acts_as_routable :ramblings, prefix: :posts
  # end
  # 
  # route_prefix = posts
  # actor   = ramblings
  # route_name   = posts_ramblings_title_me_silly
  # route_path   = posts_ramblings_title_me_silly_path
  # route_url    = posts_ramblings_title_me_silly_url
  # @post.path   = /posts/ramblings/title-me-silly
  # @post.url    = http://example.com/posts/ramblings/title-me-silly
  # 
  # 
  # class Post < ActiveRecord::Base
  #   acts_as_routable :ramblings, prefix: [:blog, :posts]
  # end
  # 
  # route_prefix = blog_posts
  # actor   = ramblings
  # route_name   = blog_posts_ramblings_title_me_silly
  # route_path   = blog_posts_ramblings_title_me_silly_path
  # route_url    = blog_posts_ramblings_title_me_silly_url
  # @post.path   = /blog/posts/ramblings/title-me-silly
  # @post.url    = http://example.com/blog/posts/ramblings/title-me-silly
  # 
  #
  # class Post < ActiveRecord::Base
  #   belongs_to :category
  #   acts_as_routable :ramblings, prefix: -> { category.name }
  # end
  # 
  # route_prefix = blog_posts
  # actor   = ramblings
  # route_name   = silly_category_ramblings_title_me_silly
  # route_path   = silly_category_ramblings_title_me_silly_path
  # route_url    = silly_category_ramblings_title_me_silly_url
  # @post.path   = /silly-category/posts/ramblings/title-me-silly
  # @post.url    = http://example.com/silly-category/posts/ramblings/title-me-silly
  # 
  #
  # class Post < ActiveRecord::Base
  #   acts_as_routable
  #   acts_as_routable :archive, prefix: [:posts]
  # end
  # 
  # route_prefix = ''
  # actor   = posts
  # route_name   = posts_title_me_silly
  # route_path   = posts_title_me_silly_path
  # route_url    = posts_title_me_silly_url
  # @post.path   = /posts/title-me-silly
  # @post.url    = http://example.com/posts/title-me-silly
  # 
  # AND
  #
  # route_prefix             = posts
  # actor                    = archive
  # route_name               = posts_archive_title_me_silly
  # route_path               = posts_archive_title_me_silly_path
  # route_url                = posts_archive_title_me_silly_url
  # @post.posts_archive_path = /posts/archive/title-me-silly
  # @post.posts_archive_url  = http://example.com/posts/archive/title-me-silly
  # 
  class RouterClasses
    
    @@router_classes = []
    
    def self.register actor, model, options
      router_class = RouterClasses.new(actor, model, options)
      @@router_classes << router_class
      return router_class
    end
    
    def self.unregister model
      @@router_classes.select{ |s| s.model == model }.each do |item|
        @@router_classes.delete(item)
      end
    end
    
    def self.router_classes
      @@router_classes
    end
    
    def self.each &block
      @@router_classes.each{ |rc| yield rc }
    end
    
    attr_reader :actor, :model
    attr_reader :prefix, :suffix, :controller_action, :no_conflict
    attr_reader :name_field_attribute, :title_field_attribute
    attr_reader :custom_route, :custom_name, :delimiter

    def initialize actor, model, options
      @actor = actor.to_s
      @model = model
      
      @name_field_attribute = :name
      @title_field_attribute = :title

      previous = @@router_classes.detect{|rc| rc.model == @model}
      raise DuplicateRouterActors.new("duplicate actors registered!") if previous.try(:route_route) == actor
      @no_conflict = !!previous
      
      @controller_action = options[:controller_action] || "#{actor}#show" 
      @name_field_attribute = options[:name_field] || :name
      @title_field_attribute = options[:title_field] || :title
      @custom_route = options[:route]
      @custom_name = options[:name]
      @prefix = options[:prefix] if options[:prefix]
      @suffix = options[:suffix] if options[:suffix]
      @delimiter = options[:delimiter] || "-"
    end

    def default_url_options
      { :host => Thread.current[:host], :port => Thread.current[:port] }
    end

    def no_conflict_model_name
      return unless no_conflict
      @model.name.underscore.downcase.split("/").last.pluralize
    end
    
    def route_base_name
      @route_base_name ||= [no_conflict_model_name, actor].compact.join("_")
    end
    
    def route_base_path
      @route_base_path ||= "/" + actor
    end
    
    def scope_name
      "flowmor_#{route_base_name}_routable"
    end
    
    def routable
      @model.send scope_name
    end
    
    def to_param value
      return unless value
      value.downcase.gsub(/[^\w\s\d\_\-]/,'').gsub(/\s\s+/,' ').gsub(/[^\w\d]/, delimiter)
    end

    def named_instance method = "router_class"
      "flowmor_#{route_base_name}_#{method}"
    end
    
    def name_field record
      record.send(name_field_attribute)
    end
    
    def title_field record
      record.send(title_field_attribute)
    end

    def name record
      name = record.send(custom_name) if custom_name
      name ||= name_field(record) || to_param(title_field(record))
      raise UnroutableRecord if name.to_s.strip.blank?
      return name
    end
    
    def route_suffix record
      return if @suffix.nil?
      Array(@suffix.is_a?(Proc) ? record.send(suffix.call) : @suffix)
    end
    
    def route_name_suffix record
      return if @suffix.nil?
      route_suffix(record).join("_") + "_"
    end
    
    def route_path_suffix record
      return if @suffix.nil?
      "/" + route_suffix(record).join("/")
    end
    
    def route_prefix record
      return if @prefix.nil?
      Array(@prefix.is_a?(Proc) ? record.send(prefix.call) : @prefix)
    end
    
    def route_name_prefix record
      return if @prefix.nil?
      route_prefix(record).join("_") + "_"
    end
    
    def route_path_prefix record
      return if @prefix.nil?
      "/" + route_prefix(record).join("/")
    end
    
    def verb_prefix verb
      return "#{verb}_" if verb
      "#{controller_action.keys.first}_" if controller_action.is_a? Hash
    end
    
    def route_name record, verb=nil
      "#{verb_prefix(verb)}#{route_name_prefix(record)}#{route_base_name}_#{route_name_suffix(record)}#{name(record)}".underscore.parameterize("_")
    end

    def route_path record
      if custom_route
        record.send(custom_route)
      else
        "#{route_path_prefix(record)}#{route_base_path}#{route_path_suffix(record)}/#{name(record)}"
      end
    end

    def route_name_method_name
      no_conflict ? "#{route_base_name}_route_name" : "route_name"
    end
    
    def url_method_name
      no_conflict ? "#{actor}_url" : "url"
    end
    
    def path_method_name
      no_conflict ? "#{actor}_path" : "path"
    end
    
    def path record
      begin
        Rails.application.routes.url_helpers.send("#{route_name(record)}_path")
      rescue NoMethodError
        raise FlowmorRouter::UnroutedRecord.new("[#{route_name(record)}] #{record.inspect} was not routed.")
      end
    end
    
    def url record
      begin
        Rails.application.routes.url_helpers.send("#{route_name(record)}_url", default_url_options)
      rescue NoMethodError
        raise FlowmorRouter::UnroutedRecord.new("[#{route_name(record)}] #{record.inspect} was not routed.")
      end
    end
  end
end
