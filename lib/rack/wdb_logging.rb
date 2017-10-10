require 'rack/wdb_logging/version'
require 'rack/wdb_logging/helpers'
require 'rack/wdb_logging/activity'
require 'rack/wdb_logging/configuration'
require 'rack/wdb_logging/hash_flattener'
require 'fluent-logger'
require 'rack/wdb_logging/railtie' if defined?(Rails::Railtie)

module Rack
  class WdbLogging
    def initialize(app, &block)
      @config = Configuration.new
      @config.instance_eval(&block) if block_given?
      raise ArgumentError, @config.error_message unless @config.valid?
      @app = app
    end

    def call(env)
      return @app.call(env) if @config.ignore_path?(env['PATH_INFO'])

      activity = Activity.new(@config) do |e|
        @app.call(e)
      end
      activity.call(env)
    end
  end
end
