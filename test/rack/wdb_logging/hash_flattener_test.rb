require 'test_helper'

class Rack::WdbLogging::HashFlattenerTest < Minitest::Test
  def test_flatten
    obj = Object.new
    expect = {
      params_test1: "test1",
      params_test2_test2: "test2",
      params_test3_test3_test3: "test3",
      params_test4_test4_test4: "test4",
      params_test5_0_test5: "test5",
      params_test6: obj.to_s
    }

    params = {
      test1: "test1",
      test2: {test2: "test2"},
      test3: {test3: {test3: "test3"}},
      "test4" => {"test4" => {"test4" => "test4"}},
      "test5" => [{test5: "test5"}],
      "test6" => obj
    }

    assert_equal expect, Rack::WdbLogging::HashFlattener.new("params").flatten(params)
  end
end
