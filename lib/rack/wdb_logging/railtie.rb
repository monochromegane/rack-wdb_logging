require 'rack/wdb_logging/trackable'

module Rack
  class WdbLogging
    class Railtie < Rails::Railtie
      config.after_initialize do
        ActionController::Base.include Rack::WdbLogging::Trackable
      end
    end
  end
end
