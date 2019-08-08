require 'sinatra/base'

class GrafanaJsonApp < Sinatra::Base
  configure :production, :development do
    enable :logging
  end
  

  def search_results(search)
    json_hash = JSON.load(File.read('./db.json'))
    case search['return']
    when 'environment_list'
      return json_hash.collect {|reg, envs| envs.keys }.flatten.to_json
    when 'region'
      env_list = search['environment'].gsub(/^[(]|[)]$/, "").split('|')
      reg_list = []
      env_list.each do |env|
        reg_list += json_hash.select { |reg, envs| envs[env] }.keys
      end
      return reg_list.uniq.to_json
    when 'namespace'
      env_list = search['environment'].gsub(/^[(]|[)]$/, "").split('|')
      namespace_list = []
      env_list.each do |env|
        namespace_list += json_hash.collect do |reg, envs|
          resource = envs[env] && envs[env].keys.include?(search['namespace']) ? envs[env][search['namespace']] : []
          resource = resource.collect { |metadata| metadata.is_a?(Hash) ? metadata[search['attribute']] : metadata } if search['attribute']
          resource
        end
      end
      return namespace_list.flatten.compact.uniq.to_json
    end
  end

  get '/' do
    'Introhive AWS Resource JSON'
  end

  post '/search' do
    content_type :json
    target = JSON.parse(request.body.read)
    search = JSON.parse(target['target'])
    return self.search_results(search)
  end

  post '/dashboard_api' do
    return search_results(params)
  end

  # For cloudwatch metrics list
  post '/cloudwatch_metrics_list_api' do
    json_hash = JSON.load(File.read('./cloudwatch_metrics_list.json'))
    namespace_list = json_hash[params['region']] if params['region']
    resource_list = namespace_list[params['namespace']] if params['namespace']
    metrics_list = resource_list[params['resource']] if params['resource']
    metrics_list = [] unless metrics_list
    case params['return']
    when 'list'
      return metrics_list.to_json
    when 'exist_status'
      result = metrics_list.include? params['metric']
      return {'status'=>result}.to_json
    end
  end

run! if __FILE__ == $0
end
