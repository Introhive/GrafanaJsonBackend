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
    assert_equal "[\"env1\",\"env2\",\"env3\",\"env4\"]", last_response.body
  end

  def test_search_region_list
    data = {
            'target' => '{"return":"region", "environment":"(env1|env4)"}'
        }
    post '/search', data.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
    assert_equal "[\"Region1\",\"Region2\"]", last_response.body
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
            'target' => '{"environment":"env1", "namespace":"AWS/ELB", "return":"namespace"}'
        }
    post '/search', data.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
    assert_equal "[\"elb1\"]", last_response.body
  end

  def test_search_namespace2
    data = {
            'target' => '{"environment":"env1", "namespace":"AWS/RDS", "return":"namespace"}'
        }
    post '/search', data.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
    assert_equal "[\"rds1\",\"rds2\"]", last_response.body
  end

  def test_search_namespace_list
    data = {
            'target' => '{"environment":"(env1|env2|env4)", "namespace":"AWS/RDS", "return":"namespace"}'
        }
    post '/search', data.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
    assert_equal "[\"rds1\",\"rds2\",\"srds1\",\"rds4\"]", last_response.body
  end

  # Does not throw error on Invalid params
  def test_search_invalid_env_namespace
    data = {
            'target' => '{"environment":"env_not_exist", "namespace":"AWS/RDS", "return":"namespace"}'
        }
    post '/search', data.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
    assert_equal "[]", last_response.body
  end

  def test_search_invalid_env_region
    data = {
            'target' => '{"environment":"env_not_exist", "return":"region"}'
        }
    post '/search', data.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
    assert_equal "[]", last_response.body
  end

  def test_search_invalid_namespace
    data = {
            'target' => '{"environment":"env1", "namespace":"Invalid", "return":"namespace"}'
        }
    post '/search', data.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
    assert_equal "[]", last_response.body
  end

end