require 'spec_helper'

describe Gliffy::API do
  let(:key) { "sample-key" }
  let(:secret) { "sample-secret" }
  let(:account_id) { 112233 }
  let(:consumer) { double(OAuth::Consumer) }
  let(:api) { Gliffy::API.new(account_id, key, secret) }

  it "has an OAuth service consumer" do
    expect(api).to respond_to :consumer
    expect(api.consumer).to be_instance_of OAuth::Consumer
  end

  context "when being initialized" do
    it "uses API key and shared secret to create a new OAuth consumer object" do
      OAuth::Consumer.should_receive(
        :new
      ).with(
        key,
        secret,
        hash_including(:site => Gliffy.web_root, :scheme => :query_string)
      ).and_return(
        consumer
      )

      api = Gliffy::API.new(account_id, key, secret)
      expect(api.consumer).to be(consumer)
    end
  end

  it "has a Gliffy API account id" do
    expect(api).to respond_to :account_id
    expect(api.account_id).to eq account_id
  end

  it "has a Giffy account" do
    response = fixture(
      "account",
      :account_id => account_id,
      :expiration => 1000
    )
    account = double(Gliffy::Account)

    Gliffy::API::Facade.any_instance.stub(:get).and_return(response)
    Gliffy::Account.should_receive(
      :load
    ).with(
      instance_of(Gliffy::API::Facade),
      response
    ).and_return(account)

    expect(api).to respond_to :account
    expect(api.account).to be account
  end

  it "has an application name" do
    expect(api).to respond_to :application_name
  end

  describe "application name" do
    it "has a default value" do
      expect(api.application_name).to eq Gliffy.default_application_name
    end

    it "can be overridden" do
      expect(api).to respond_to :application_name=

      test_name = "TEST APP NAME"
      api.application_name = test_name
      expect(api.application_name).to eq test_name
    end
  end

  it "has a plain HTTP API facade" do
    expect(api).to respond_to :plain
    expect(api.plain).to be_instance_of Gliffy::API::Facade
  end

  it "has a secure HTTPS API facade" do
    expect(api).to respond_to :secure
    expect(api.secure).to be_instance_of Gliffy::API::Facade
  end

  it "handles GET requests" do
    expect(api).to respond_to :get
  end

  it "handles raw GET requests" do
    expect(api).to respond_to :raw
  end

  it "handles POST requests" do
    expect(api).to respond_to :post
  end

  it "generates signed web links" do
    expect(api).to respond_to :web
  end

  context "when doing a request" do
    let(:url) { 'http://www.gliffy.com/test' }
    let(:params) { { :param => 'value' } }
    let(:xml) { fixture_xml("document", :document_id => 11, :document_name => "TEST" ) }
    let(:raw) { double(Object, :body => xml) }

    it "delegates to 'raw' call when doing GET" do
      api.should_receive(
        :raw
      ).with(
        url, params
      ).and_return(xml)

      result = api.get(url, params)

      expect(result.exists('//g:documents')).to be_true
    end

    it "delegates raw GET requsts to OAuth token instance" do
      OAuth::AccessToken.any_instance.should_receive(
        :get
      ).with(
        'http://www.gliffy.com/test?param=value'
      ).and_return(raw)

      result = api.raw(url, params)
      expect(
        result
      ).to eq xml
    end

    it "delegates POST requests to OAuth token instance" do
      OAuth::AccessToken.any_instance.should_receive(
        :post
      ).with(
        url,
        params
      ).and_return(raw)

      result = api.post(url, params)
      expect(
        result
      ).to be_instance_of Gliffy::API::Response
      expect(result.exists('//g:documents')).to be_true
    end

    it "delegates signed links generation to OAuth consumer" do
      signed_url = "mock signed url value"

      OAuth::Consumer.any_instance.should_receive(
        :create_signed_request
      ).with(
        :get,
        'http://www.gliffy.com/test?param=value',
        instance_of(OAuth::AccessToken)
      ).and_return(double(Object, :path => signed_url))

      expect(api.web(url, params)).to eq signed_url
    end
  end

  it "allows to impersonate user" do
    expect(api).to respond_to :impersonate
  end

  context "when impersonating user" do
    let(:response) { Gliffy::API::Response.new(fixture("token")) }

    it "sends POST to correct URL" do
      escaped_user = URI.escape 'test@test.com'

      Gliffy::API::Facade.any_instance.should_receive(
        :post
      ).with(
        "/accounts/#{account_id}/users/#{escaped_user}/oauth_token.xml",
        hash_including(:action => "create")
      ).and_return(
        response
      )

      api.impersonate("test@test.com")      
    end

    it "updates OAuth token using server response" do
      Gliffy::API::Facade.any_instance.should_receive(
        :post
      ).and_return(
        response
      )

      OAuth::AccessToken.any_instance.should_receive(
        :token=
      ).with(
        "140a1b58c248d13872499df769606766"
      )

      OAuth::AccessToken.any_instance.should_receive(
        :secret=
      ).with(
        "481830f5827e35b0644a32c1caac5245"
      )

      api.impersonate("test@test.com")
    end
  end
end
