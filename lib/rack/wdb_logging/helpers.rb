module Rack
  module WdbLogging::Helpers
    def headers
      @config.headers.inject({}) do |headers, header|
        if env.key?(header)
          key = header.gsub(/^HTTP_X_|^HTTP_/, '').downcase.to_sym
          headers[key] = env[header]
        end
        headers
      end
    end

    def cookies
      @config.cookies.inject({}) do |cookies, cookie|
        if request.cookies.key?(cookie.to_s)
          cookies[cookie.to_sym] = request.cookies[cookie.to_s]
        end
        cookies
      end
    end

    def request_envs
      @config.request_envs.inject({}) do |request_envs, request_env|
        request_envs.merge!(env[request_env.to_s]) if env.key?(request_env.to_s)
        request_envs
      end
    end

    def response_time
      '%0.6f' % @response_time
    end

    def status_code
      @c.to_s
    end

    def remote_addr
      (env['action_dispatch.remote_ip'] || request.ip).to_s
    end

    def dump
      results = {}
      Rack::WdbLogging::Helpers.instance_methods.each do |m|
        next if m == :dump

        result = send(m)
        next unless result

        if result.is_a?(Hash)
          results.merge!(result)
        else
          results[m] = result
        end
      end
      results
    end
  end
end
