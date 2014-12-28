require 'uri'
require 'oauth'
require 'nokogiri'
require 'cgi'

module Gliffy
  class API
    attr_reader :consumer
    attr_reader :api_consumer # used to create a web link, but via api_root 
    attr_reader :account_id
    attr_accessor :application_name

    def initialize(account_id, key, secret)
      @consumer = init_consumer(key, secret)
      @api_consumer = init_api_consumer(key, secret) # used to create a web link, but via api_root
      @account_id = account_id
      @application_name = Gliffy.default_application_name
    end

    def plain
      Gliffy::API::Facade.http(self)
    end

    def secure
      Gliffy::API::Facade.https(self)
    end

    def get(url, params = {})
      Gliffy::API::Response.new(Nokogiri.XML(raw(url, params)))
    end

    def raw(url, params = {})
      r = token.get(url + '?' + query(params))
      r.body
    end

    def post(url, params)
      r = token.post(url, params)
      Gliffy::API::Response.new(Nokogiri.XML(r.body))
    end

    def web(url, params)
      consumer.create_signed_request(
        :get,
        url + '?' + query(params),
        token
      ).path
    end

    # Use this method to obtain a URL that goes via the api_root endpoint
    def web_by_api(url, params) ###
      api_consumer.create_signed_request(
        :get,
        url + '?' + query(params),
        token
      ).path
    end

    def account
      @account ||= load_account
    end

    def impersonate(user)
      escaped_id = URI.escape @account_id.to_s
      escaped_user = URI.escape user

      response = secure.post(
        "/accounts/#{escaped_id}/users/#{escaped_user}/oauth_token.xml",
        :action => 'create',
        :description => application_name
      )

      token.token = response.string('//g:oauth-token')
      token.secret = response.string('//g:oauth-token-secret')
    end

    private

    def query(params)
      params.map {|k, v| "#{CGI.escape k.to_s}=#{CGI.escape v.to_s}" }.join('&')
    end

    def token
      @token ||= OAuth::AccessToken.new @consumer
    end

    def load_account
      response = plain.get("/accounts/#{account_id}.xml",
                          { :action => 'get' })
      Gliffy::Account.load(plain, response)
    end

    def init_consumer(key, secret)
      OAuth::Consumer.new(key,
                          secret,
                          :site => Gliffy.web_root,
                          :scheme => :query_string)
    end

    # This consumer creates requests that go to the API endpoint.
    def init_api_consumer(key, secret)
      OAuth::Consumer.new(key,
                          secret,
                          :site => Gliffy.api_root,
                          :scheme => :query_string)
    end 
  end
end