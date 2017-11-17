require_relative '../app'
require 'minitest/autorun'
require 'rack/test'

class MyAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    GrafanaJsonApp
  end

  def test_my_default
    get '/'
    assert_equal 'Introhive AWS Resource JSON', last_response.body
  end

  def test_search_environment
    data = {
            'target' => '{"environment":"list"}'
        }
    post '/search', data.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
    assert_equal "[\"env1\",\"env2\",\"env3\"]", last_response.body
  end

  def test_search_namespace
    data = {
            'target' => '{"environment":"env1", "namespace":"AWS/ELB"}'
        }
    post '/search', data.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
    assert_equal "[\"elb1\"]", last_response.body
  end
end