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

      def acts_as_routable(actor = nil, options = {})
        # juggle what was passed in to correct variables
        actor, options = nil, actor if actor.is_a?(Hash) && options == {}
        if actor.nil?
          singular_name = name.underscore.downcase.split("/").last
          actor = singular_name.pluralize 
          options[:controller_action] = options[:controller_action] || "#{singular_name}#show"
        end
        
        # Register and assign a distinctive name to the router_class
        router_class = FlowmorRouter::RouterClasses.register(actor, self, options)
        puts "REGISTERED #{router_class.named_instance}"
        class_attribute router_class.named_instance
        self.send "#{router_class.named_instance}=", router_class

        scope router_class.scope_name, options[:scope] || lambda {}

        define_method router_class.route_name_method_name do 
          router_class.route_name self
        end
        
        define_method router_class.url_method_name do 
          router_class.url self
        end
        
        define_method router_class.path_method_name do 
          router_class.path self
        end
        
        begin
          Rails.application.routes_reloader.reload! unless Rails.configuration.eager_load
        rescue SystemStackError
          # NOP -- Supressing Stack Level Too deep error
          # caused by models being loaded lazily during development mode.
        end
      end
    end
  end
end
 
ActiveRecord::Base.send :include, FlowmorRouter::ActsAsRoutable