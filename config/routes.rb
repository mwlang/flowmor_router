Rails.application.routes.draw do

  Rails.logger.debug "FlowmorRouter REDRAWING ROUTES for #{FlowmorRouter::RouterClasses.router_classes.map{|m| m.model.name.to_s}}"
  
  # Routes from app/view/static
  Dir.glob(File.join(Rails.root, 'app', 'views', 'static', '*')).reject{|r| File.directory?(r)}.each do |fn|
    route = File.basename fn.split(".").first
    # ignore partials
    if route[0] != "_"
      get("/#{route.gsub("_", "-")}", to: "static##{route}", as: "static_#{route.gsub("-", "_")}") 
    end
  end

  FlowmorRouter::RouterClasses.router_classes.each do |router_class|
    Rails.logger.debug "FlowmorRouter MODEL: #{router_class.model.name}"
    router_class.routable.each do |record|
      Rails.logger.debug "FlowmorRouter ROUTING: #{router_class.route_path(record)} to: #{router_class.controller_action} defaults: { id: #{record.id} } as: #{router_class.route_name(record)}"
      if router_class.controller_action.is_a? String
        get router_class.route_path(record),
          to: router_class.controller_action,
          defaults: { id: record.id },
          as: router_class.route_name(record)
      elsif router_class.controller_action.is_a? Hash
        router_class.controller_action.each_pair do |verb, action|
          match router_class.route_path(record),
            to: action,
            defaults: { id: record.id },
            via: verb,
            as: "#{router_class.route_name(record, verb)}"
        end
      end
    end
  end
end
