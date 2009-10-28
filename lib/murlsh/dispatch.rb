%w{
murlsh

rubygems
active_record
rack
sqlite3

yaml
}.each { |m| require m }

module Murlsh

  # Dispatch requests.
  class Dispatch

    # Set up config hash and database connection.
    def initialize
      @config = YAML.load_file('config.yaml')
      @url_root = URI(@config.fetch('root_url')).path

      ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3', :database => @config.fetch('db_file'))

      @db = ActiveRecord::Base.connection.instance_variable_get(:@connection)

      @url_server = Murlsh::UrlServer.new(@config, @db)
    end

    # Rack call.
    def call(env)
      dispatch = {
        ['GET', @url_root] => [@url_server, :get],
        ['POST', @url_root] => [@url_server, :post],
        ['GET', "#{@url_root}url"] => [@url_server, :get],
        ['POST', "#{@url_root}url"] => [@url_server, :post],
      }
      dispatch.default = [self, :not_found]

      req = Rack::Request.new(env)

      obj, meth = dispatch[[req.request_method, req.path]]

      obj.send(meth, req).finish
    end

    # Called if the request is not found.
    def not_found(req)
      Rack::Response.new("<p>#{req.url} not found</p>

<p><a href=\"#{@config['root_url']}\">root<a></p>
",
        404, { 'Content-Type' => 'text/html' })
    end

  end

end
