require 'test_helper'
require 'rack/test'

class TestApp
  def call(env)
    [
      200,
      { 'Content-Type' => 'text/html' },
      ['<html><head></head><body></body></html>']
    ]
  end
end

class Rack::WdbLoggingTest < Minitest::Test

  include Rack::Test::Methods

  def app
    callback = -> (activity) { @activity = activity }
    Rack::Builder.new {
      map "/" do
        use ::Rack::WdbLogging do |conf|
          conf.db_name     = 'db_name'
          conf.environment = 'development'
          conf.after_run_app_callbacks << callback
        end
        run TestApp.new
      end
    }.to_app
  end

  def test_activity_content
    get '/path', {key: :value}, {
      'HTTP_USER_AGENT'      => 'ua',
      'HTTP_X_FORWARDED_FOR' => '1.2.3.4, 2.3.4.5',
      'HTTP_REFERER'         => 'https://www.google.co.jp/'
    }
    assert last_response.ok?

    refute_nil @activity[:response_time]
    assert_equal '200',                       @activity[:status_code]
    assert_equal '2.3.4.5',                   @activity[:remote_addr]
    assert_equal 'example.org',               @activity[:host]
    assert_equal 'GET',                       @activity[:request_method]
    assert_equal '/path',                     @activity[:path_info]
    assert_equal 'key=value',                 @activity[:query_string]
    assert_equal 'ua',                        @activity[:user_agent]
    assert_equal '1.2.3.4, 2.3.4.5',          @activity[:forwarded_for]
    assert_equal 'https://www.google.co.jp/', @activity[:referer]
  end

  def test_ignore_patterns
    get '/assets/picture'
    assert last_response.ok?
    assert_nil @activity
  end

  def test_activity_from_cookie
    clear_cookies
    set_cookie "uid=abc"

    get '/'
    assert last_response.ok?
    assert_equal 'abc', @activity[:uid]
  end

  def test_activity_from_request_env
    get '/', {}, {'wdb_logging' => {hoge: :fuga}}
    assert last_response.ok?
    assert_equal :fuga, @activity[:hoge]
  end
end

class Rack::WdbLoggingArgumentErrorTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Rack::Builder.new {
      map "/" do
        use ::Rack::WdbLogging
        run TestApp.new
      end
    }.to_app
  end

  def test_argument_error
    assert_raises(ArgumentError, 'db_name and environment must be set!') do
      get '/'
    end
  end
end
