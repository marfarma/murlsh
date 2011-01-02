require 'active_record'
require 'rack'

module Murlsh

  # Build responses for HTTP requests.
  class UrlServer

    include HeadFromGet

    def initialize(config)
      @config = config
    end

    # Respond to a GET request. Return a page of urls based on the query
    # string parameters.
    def get(req)
      last_update = Murlsh::Url.maximum('time')

      resp = Rack::Response.new

      resp['Cache-Control'] = 'must-revalidate, max-age=0'
      resp['Content-Type'] = 'text/html; charset=utf-8'
      resp['ETag'] = "W/\"#{last_update.to_i}#{req.params.sort.join}\""
      resp['Last-Modified'] = last_update.httpdate  if last_update

      resp.body = Murlsh::UrlBody.new(@config, req, resp['Content-Type'])

      resp
    end

    # Respond to a POST request. Add the new url and return json.
    def post(req)
      auth = req.params['auth']
      if user = auth.empty? ? nil : Murlsh::Auth.new(
        @config.fetch('auth_file')).auth(auth)

        mu = Murlsh::Url.new do |u|
          u.time = if req.params['time']
            Time.at(req.params['time'].to_f).utc
          else
            Time.now.utc
          end
          u.url = req.params['url']
          u.email = user[:email]
          u.name = user[:name]
          u.via = req.params['via']  unless req.params['via'].to_s.empty?
          unless req.params['thumbnail'].to_s.empty?
            u.thumbnail_url = req.params['thumbnail']
          end
        end

        begin
          # validate before add_pre plugins have run and also after (in save!)
          raise ActiveRecord::RecordInvalid.new(mu)  unless mu.valid?
          Murlsh::Plugin.hooks('add_pre') { |p| p.run mu, @config }
          mu.save!
          Murlsh::Plugin.hooks('add_post') { |p| p.run mu, @config }
          response_body, response_code = [mu], 200
        rescue ActiveRecord::RecordInvalid => error
          response_body = {
            'url' => error.record,
            'errors' => error.record.errors,
            }
          response_code = 500
        end
      else
        response_body, response_code = '', 403
      end

      Rack::Response.new(response_body.to_json, response_code, {
        'Content-Type' => 'application/json' })
    end

  end

end
