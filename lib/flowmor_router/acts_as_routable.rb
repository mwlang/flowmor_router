module FlowmorRouter
  module ActsAsRoutable
    extend ActiveSupport::Concern
    
    included do
      after_save :reload_routes

      def reload_routes
        Rails.application.routes_reloader.reload!
      end
    end

    module ClassMethods

      # Register and assign a distinctive name to the router_class
      def initialize_router_class actor, options
        FlowmorRouter::RouterClasses.register(actor, self, options).tap do |router_class|
          class_attribute router_class.named_instance
          self.send "#{router_class.named_instance}=", router_class
        end
      end

      # Set up the scope that can be called to get which records should be routed
      def set_routable_scope(router_class, routable_scope)
        scope router_class.scope_name, routable_scope || -> {}
      end

      # Set up reflective methods back to the router_class
      def define_routable_methods router_class
        define_method router_class.route_name_method_name do 
          router_class.route_name self
        end
        
        define_method router_class.url_method_name do 
          router_class.url self
        end
        
        define_method router_class.path_method_name do 
          router_class.path self
        end
      end
      
      # Cause the routes to be redrawn unless we're eager loading or testing
      # In the case of eager loading, the routes will finally be drawn only after
      # all the model files have been loaded.
      def prepare_routes
        return if Rails.configuration.eager_load || Rails.env == "test" 
        begin
          Rails.application.routes_reloader.reload! 
        rescue SystemStackError
          # NOP -- Supressing Stack Level Too deep error
          # caused by models being loaded lazily during development mode.
        end
      end
      
      def acts_as_routable(actor = nil, options = {})
        # juggle what was passed in to correct variables
        actor, options = nil, actor if actor.is_a?(Hash) && options == {}
        if actor.nil?
          singular_name = name.underscore.downcase.split("/").last
          actor = singular_name.pluralize 
          options[:controller_action] = options[:controller_action] || "#{singular_name}#show"
        end
        
        router_class = initialize_router_class actor, options
        set_routable_scope router_class, options[:scope]
        define_routable_methods router_class
        prepare_routes
      end
    end
  end
end
 
ActiveRecord::Base.send :include, FlowmorRouter::ActsAsRoutable