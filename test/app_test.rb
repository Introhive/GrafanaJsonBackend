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

  # Test API calls

  def test_api_search_environment_list
    data = {"return": "environment_list"}
    post '/dashboard_api', data
    assert last_response.ok?
    assert_equal "[\"env1\",\"env2\",\"env3\",\"env4\"]", last_response.body
  end

  def test_api_search_region_list
    data = {"return":"region", "environment":"(env1|env4)"}
    post '/dashboard_api', data
    assert last_response.ok?
    assert_equal "[\"Region1\",\"Region2\"]", last_response.body
  end

  def test_api_search_environment_region1
    data = {"environment":"env2", "return":"region"}
    post '/dashboard_api', data
    assert last_response.ok?
    assert_equal "[\"Region1\"]", last_response.body
  end

  def test_api_search_namespace1
    data = {"environment":"env1", "namespace":"AWS/ELB", "return":"namespace"}
    post '/dashboard_api', data
    assert last_response.ok?
    assert_equal "[\"elb1\"]", last_response.body
  end

  def test_api_search_namespace2
    data = {"environment":"env1", "namespace":"AWS/RDS", "return":"namespace"}
    post '/dashboard_api', data
    assert last_response.ok?
    assert_equal "[\"rds1\",\"rds2\"]", last_response.body
  end

  def test_api_search_namespace_list
    data = {"environment":"(env1|env2|env4)", "namespace":"AWS/RDS", "return":"namespace"}
    post '/dashboard_api', data
    assert last_response.ok?
    assert_equal "[\"rds1\",\"rds2\",\"srds1\",\"rds4\"]", last_response.body
  end

  # Does not throw error on Invalid params
  def test_api_search_invalid_env_namespace
    data = {"environment":"env_not_exist", "namespace":"AWS/RDS", "return":"namespace"}
    post '/dashboard_api', data
    assert last_response.ok?
    assert_equal "[]", last_response.body
  end

  def test_api_search_invalid_env_region
    data = {"environment":"env_not_exist", "return":"region"}
    post '/dashboard_api', data
    assert last_response.ok?
    assert_equal "[]", last_response.body
  end

  def test_api_search_invalid_namespace
    data = {"environment":"env1", "namespace":"Invalid", "return":"namespace"}
    post '/dashboard_api', data
    assert last_response.ok?
    assert_equal "[]", last_response.body
  end

  # Test cloudwatch metrics list

  def test_api_cloudwatch_metrics_list1
    data = {"return": "list", "region": "reg1", "namespace": "AWS/RDS", "resource": "rds1"}
    post '/cloudwatch_metrics_list_api', data
    assert last_response.ok?
    assert_equal "[\"m1\",\"m2\",\"m3\"]", last_response.body
  end

  def test_api_cloudwatch_metrics_list2
    data = {"return": "list", "region": "reg2", "namespace": "AWS/RDS", "resource": "rds4"}
    post '/cloudwatch_metrics_list_api', data
    assert last_response.ok?
    assert_equal "[\"m1\"]", last_response.body
  end

  def test_api_cloudwatch_metrics_exist1
    data = {"return": "exist_status", "region": "reg1", "namespace": "AWS/RDS", "resource": "rds1", "metric": "m1"}
    post '/cloudwatch_metrics_list_api', data
    assert last_response.ok?
    assert_equal "{\"status\":true}", last_response.body
  end

  def test_api_cloudwatch_metrics_exist2
    data = {"return": "exist_status", "region": "reg2", "namespace": "AWS/RDS", "resource": "rds4", "metric": "m10"}
    post '/cloudwatch_metrics_list_api', data
    assert last_response.ok?
    assert_equal "{\"status\":false}", last_response.body
  end

  def test_api_cloudwatch_metrics_list_invalid
    data = {"return": "list", "region": "reg2", "namespace": "AWS/RDS", "resource": "rds10"}
    post '/cloudwatch_metrics_list_api', data
    assert last_response.ok?
    assert_equal "[]", last_response.body
  end

  def test_api_cloudwatch_metrics_exist_invalid
    data = {"return": "exist_status", "region": "reg2", "namespace": "AWS/RDS", "resource": "rds4"}
    post '/cloudwatch_metrics_list_api', data
    assert last_response.ok?
    assert_equal "{\"status\":false}", last_response.body
  end

end