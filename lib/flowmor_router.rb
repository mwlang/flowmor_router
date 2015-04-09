require "flowmor_router/engine"
require "flowmor_router/exceptions"
require "flowmor_router/acts_as_flowmor_routable"

module FlowmorRouter

  class HostAndPortGrabber
    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)
      Thread.current[:host] = req.host
      Thread.current[:port] = req.port
      
      @app.call(env)
    end
  end

  class Engine < ::Rails::Engine
    config.flowmor_router = FlowmorRouter
    config.app_middleware.insert_after(ActionDispatch::ParamsParser, FlowmorRouter::HostAndPortGrabber)
  end
end
