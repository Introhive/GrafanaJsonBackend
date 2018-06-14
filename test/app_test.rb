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

  def test_search_environment_list
    data = {
            'target' => '{"return":"environment_list"}'
        }
    post '/search', data.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
    assert_equal "[\"env1\",\"env2\",\"env3\",\"env1\"]", last_response.body
  end

  def test_search_environment_region1
    data = {
            'target' => '{"environment":"env2", "return":"region"}'
        }
    post '/search', data.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
    assert_equal "[\"Region1\"]", last_response.body
  end

  def test_search_namespace1
    data = {
            'target' => '{"environment":"env1", "namespace":"AWS/ELB", "region":"Region1", "return":"namespace"}'
        }
    post '/search', data.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
    assert_equal "[\"elb1\"]", last_response.body
  end

  def test_search_namespace2
    data = {
            'target' => '{"environment":"env1", "namespace":"AWS/RDS", "region":"Region1", "return":"namespace"}'
        }
    post '/search', data.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
    assert_equal "[\"rds1\",\"rds2\"]", last_response.body
  end
end