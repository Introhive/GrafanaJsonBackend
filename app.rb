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
        namespace_list += json_hash.collect { |reg, envs| envs[env][search['namespace']] if envs[env] && envs[env].keys.include?(search['namespace']) }
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

run! if __FILE__ == $0
end
