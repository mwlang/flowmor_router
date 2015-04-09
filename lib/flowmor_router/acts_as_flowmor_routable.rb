module FlowmorRouter
  module ActsAsFlowmorRoutable
    extend ActiveSupport::Concern
    
    def controller_action
      self.class.controller_action
    end

    included do
      
      after_save :reload_routes
      before_save :populate_name

      def derived_name_field_value
        send(self.derived_name_field)
      end

      def reload_routes
        Rails.application.routes_reloader.reload!
      end

      def populate_name
        if attributes[name_field].blank? || name_field_changed?
          send("#{name_field}=", new_name_value)
        end
      end

      def route_prefix
        "/#{self.route_model.pluralize.gsub('_', '-')}"
      end

      def route
        "#{route_prefix}/#{new_name_value}"
      end

      def default_url_options
        { :host => Thread.current[:host], :port => Thread.current[:port] }
      end

      def url
        begin
          FlowmorRouter::Engine.routes.url_helpers.send("#{route_name}_url", default_url_options)
        rescue NoMethodError
          raise FlowmorRouter::UnroutedRecord.new("#{self.inspect} was not routed.")
        end
      end
      def name_field
        self.class.name_field
      end

      def name_field_value
        attributes[name_field]
      end

      def path
        begin
          Rails.application.routes.url_helpers.send("#{route_name}_path")
        rescue NoMethodError
          raise FlowmorRouter::UnroutedRecord.new("#{self.inspect} was not routed.")
        end
      end

      def route_name
        name_suffix = new_name_value
        raise UnroutableRecord if name_suffix.blank?

        "#{route_name_prefix}_#{name_suffix}".underscore
      end

      def route_name_prefix
        "#{self.route_model.pluralize}"
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

    end

    module LocalInstanceMethods
    end
    
    module ClassMethods
      def default_controller_action
        "#{self.route_model.underscore}#show"
      end

      def controller_action
        @controller_action || default_controller_action
      end

      def acts_as_routable(options = {})
        ROUTABLE_MODEL_CLASSES << self
        scope :routable, options[:scope] || lambda {}

        class_attribute :route_model
        self.route_model = options[:route_model] || name.underscore.downcase

        class_attribute :name_field
        self.name_field = (options[:name_field] || :name).to_s

        class_attribute :derived_name_field
        self.derived_name_field = (options[:derived_name_field] || :title).to_s

        class_attribute :controller_action
        self.controller_action = (options[:controller_action] || default_controller_action)
        
        include LocalInstanceMethods
      end
    end
  end
end
 
ActiveRecord::Base.send :include, FlowmorRouter::ActsAsFlowmorRoutable