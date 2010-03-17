$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

require 'rack/test'

describe Murlsh::Dispatch do
  include Rack::Test::Methods

  def app
    config = YAML.load_file(File.join('..', 'config.yaml'))
    config['db_file'] = File.join('..', config['db_file'])
    Murlsh::Dispatch.new(config)
  end

  it 'should return ok for GET /' do
    get '/'
    last_response.should be_ok
  end

  it 'should return 404 for an invalid request' do
    get '/foo'
    last_response.should_not be_ok
  end
end
