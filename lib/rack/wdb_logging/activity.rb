module Rack
  class WdbLogging::Activity
    def initialize(config, &block)
      @config = config
      @rack   = block
    end

    def call(env)
      began_at = ms(Time.now)

      @env = env
      @c, @h, @b = @rack.call(env)

      @timestamp = Time.now
      @response_time = ms(@timestamp) - began_at

      after_run_app_callbacks.each {|callback| callback.call(dump)}

      return @c, @h, @b
    end

    include Rack::WdbLogging::Helpers

    private

    def env
      @env ||= {}
    end

    def request
      @request ||= Rack::Request.new(env)
    end

    def ms(time)
      time.to_i + (time.usec/1000000.0)
    end

    def after_run_app_callbacks
      [callback].concat(@config.after_run_app_callbacks)
    end

    def callback
      ->(activity) { @config.logger.post('activity', activity) }
    end
  end
end

