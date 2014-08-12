Rails.application.routes.draw do

  # Routes from RoutableRecord descendants
  RoutableRecord.descendants.each do |model|
    model.all.each do |record|
      get record.route,
      to: record.controller_action,
      defaults: { id: record.id },
      as: record.route_name
    end
  end
  
  # Routes from app/view/static
  Dir.glob(File.join(Rails.root, 'app', 'views', 'static', '*')).reject{|r| File.directory?(r)}.each do |fn|
    route = File.basename fn.split(".").first
    # ignore partials
    if route[0] != "_"
      get("/#{route}", to: "static##{route}", as: "static_#{route}") 
    end
  end
end
