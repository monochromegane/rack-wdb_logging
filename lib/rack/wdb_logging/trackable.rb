module Rack
  class WdbLogging
    module Trackable
      extend ActiveSupport::Concern
      included do
        around_action :set_wdb_logging_activity
      end

      private

      def set_wdb_logging_activity
        yield
      ensure
        params_to_activity
      end

      def params_to_activity
        wdb_logging_env[:original_params] = filtered_params
        wdb_logging_env.merge!(flatten_hash(:params, filtered_params).reject do |key, _|
            # Avoid increasing unnecessary columns on database.
            key.to_s.count('_') > 3
        end)
      end

      def set_activity(key, value)
        wdb_logging_env.merge!(flatten_hash(key, value))
      end

      def flatten_hash(key, hash)
        Rack::WdbLogging::HashFlattener.new(key).flatten(hash)
      end

      def wdb_logging_env
        request.env['wdb_logging'] ||= {}
      end

      def filtered_params
        @filtered_params ||= begin
          filters = Rails.application.config.filter_parameters
          ActionDispatch::Http::ParameterFilter.new(filters).filter(params_as_hash)
        end
      end

      def params_as_hash
        if params.respond_to?(:to_unsafe_h)
          params.to_unsafe_h
        else
          params
        end
      end
    end
  end
end
