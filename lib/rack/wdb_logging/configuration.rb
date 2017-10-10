module Rack
  class WdbLogging::Configuration

    DEFAULT_IGNORE_PATH_PATTERNS = [ /\A\/assets/ ]
    DEFAULT_HEADERS = %w(
        HTTP_X_FORWARDED_FOR
        HTTP_HOST
        HTTP_USER_AGENT
        HTTP_REFERER
        REQUEST_METHOD
        PATH_INFO
        QUERY_STRING
    )
    DEFAULT_COOKIES = [ :uid ]
    DEFAULT_REQUEST_ENVS = [ :wdb_logging ]

    attr_accessor :db_name, :environment, :enable_fluent, :fluent_host, :fluent_port
    attr_reader   :error_message

    def after_run_app_callbacks
      @callbacks ||= []
    end

    def ignore_path_patterns
      @ignore_path_patterns ||= DEFAULT_IGNORE_PATH_PATTERNS
    end

    def event_path_patterns
      @event_path_patterns ||= []
    end

    def headers
      @headers ||= DEFAULT_HEADERS
    end

    def cookies
      @cookies ||= DEFAULT_COOKIES
    end

    def request_envs
      @envs ||= DEFAULT_REQUEST_ENVS
    end

    def ignore_path?(path)
      ignore_path_patterns.any? {|ignore| ignore =~ path}
    end

    def valid?
      if !db_name || !environment
        @error_message = 'db_name and environment must be set!'
        return false
      end
      true
    end

    def logger
      @logger ||= if enable_fluent
                    Fluent::Logger::FluentLogger.new(td_db_name,
                      host: fluent_host || 'localhost',
                      port: fluent_port || 24224
                    )
                  else
                    Fluent::Logger::NullLogger.new
                  end
    end

    private

    def td_db_name
      environment.to_s == 'production' ? db_name : "#{db_name}_#{environment}"
    end
  end
end

