require 'sinatra/base'

class GrafanaJsonApp < Sinatra::Base
  configure :production, :development do
    enable :logging
  end
  
  json_hash = JSON.load(File.read('./db.json'))

  get '/' do
    'Introhive AWS Resource JSON'
  end

  post '/search' do
    content_type :json
    target = JSON.parse(request.body.read)
    search = JSON.parse(target['target'])

    case search['return']
    when 'environment_list'
      return json_hash.collect {|reg, envs| envs.keys }.flatten.to_json
    when 'region'
      result = json_hash.select { |reg, envs| envs[search['environment']] }.keys
      return result.to_json if result
    when 'region_list'
      env_list = search['environment'].gsub(/^[(]|[)]$/, "").split('|')
      reg_list = []
      env_list.each do |env|
        reg_list += json_hash.select { |reg, envs| envs[env] }.keys
      end
      return reg_list.uniq.to_json
    when 'namespace'
      if json_hash.include?(search['region']) and json_hash[search['region']].keys.include?(search['environment'])
        return json_hash[search['region']][search['environment']][search['namespace']].to_json if search['namespace'] != nil
      end
    end
  end

run! if __FILE__ == $0
end
