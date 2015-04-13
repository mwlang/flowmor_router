Rails.application.routes.draw do

  puts "REDRAWING ROUTES for #{FlowmorRouter::RouterClasses.router_classes.map{|m| m.model.name.to_s}}"
  
  # Routes from app/view/static
  Dir.glob(File.join(Rails.root, 'app', 'views', 'static', '*')).reject{|r| File.directory?(r)}.each do |fn|
    route = File.basename fn.split(".").first
    # ignore partials
    if route[0] != "_"
      get("/#{route.gsub("_", "-")}", to: "static##{route}", as: "static_#{route.gsub("-", "_")}") 
    end
  end

  FlowmorRouter::RouterClasses.router_classes.each do |router_class|
    puts "   MODEL: #{router_class.model.name}"
    router_class.routable.each do |record|
      puts "   ROUTING: #{router_class.route_path(record)} to: #{router_class.controller_action} defaults: { id: #{record.id} } as: #{router_class.route_name(record)}"
      get router_class.route_path(record),
        to: router_class.controller_action,
        defaults: { id: record.id },
        as: router_class.route_name(record)
    end
  end
end
