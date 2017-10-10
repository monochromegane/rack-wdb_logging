$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'active_support/concern'
require 'rack/wdb_logging'
require 'rack/wdb_logging/trackable'

module Rack
  class WdbLogging
    class DummyTrackableController
      def self.around_action(name); end
      include Rack::WdbLogging::Trackable

      attr_accessor :params

      def wdb_logging_env
        @env ||= {}
      end

      def filtered_params
        params_as_hash
      end
    end
  end
end

require 'minitest/autorun'
