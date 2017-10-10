require 'test_helper'

class Rack::WdbLogging::TrackableTest < Minitest::Test
  def test_set_activity
    controller = Rack::WdbLogging::DummyTrackableController.new
    controller.send(:set_activity, 'key1', 'value1')
    controller.send(:set_activity, 'key2', {'key22' => 'value22'})

    assert_equal 'value1', controller.wdb_logging_env[:key1]
    assert_equal 'value22', controller.wdb_logging_env[:key2_key22]
  end

  def test_params_to_activity
    controller = Rack::WdbLogging::DummyTrackableController.new
    controller.params = {
      'key3' => {'key32' => {'key33' => 'value33'}},
      'key4' => {'key42' => {'key43' => {'key44' => 'value44'}}}
    }
    controller.send(:params_to_activity)

    assert_equal controller.params, controller.wdb_logging_env[:original_params]
    assert_equal 'value33', controller.wdb_logging_env[:params_key3_key32_key33]
    refute controller.wdb_logging_env.key?(:params_key4_key42_key43_key44)
  end

  def test_params_to_activity_for_rails5
    controller = Rack::WdbLogging::DummyTrackableController.new
    params = Object.new
    def params.to_unsafe_h
      {
        'key3' => {'key32' => {'key33' => 'value33'}},
        'key4' => {'key42' => {'key43' => {'key44' => 'value44'}}}
      }
    end
    controller.params = params
    controller.send(:params_to_activity)

    assert_equal params.to_unsafe_h, controller.wdb_logging_env[:original_params]
    assert_equal 'value33', controller.wdb_logging_env[:params_key3_key32_key33]
    refute controller.wdb_logging_env.key?(:params_key4_key42_key43_key44)
  end
end
