module FlowmorRouter
  class Engine < ::Rails::Engine
    include Rails::Initializable

    # In development mode (i.e. eager_load == false), models are lazily loaded, 
    # so we hunt for them and explicitly require them to trigger the route redraws
    initializer :set_routes_reloader_hook do
      if !Rails.configuration.eager_load
        begin
          models_path = File.join(Rails.root, 'app', 'models', '*')
          routable_models = `grep -lr acts_as_routable #{models_path}`.split("\n")
          routable_models.each do |fn|
            Rails.logger.debug "PRELOADING: #{fn}"
            require fn
          end
        rescue Exception => err
          Rails.logger.error "FlowmorRouter: set_routes_reloader_hook could not pre-load routable models: #{err.message}"
        end
      end
    end
    
  end
end
