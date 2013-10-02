require 'spec_helper'

shared_examples_for "an API facade" do
  context "when sending GET request" do
    it "forwards request to the API backend with HTTP protocol" do
      api.should_receive(
                         :get
                         ).with(
                                match(url_matcher),
                                hash_including(params)
                                ).and_return(response)

      expect(facade.get("/test", params)).to be response
    end
  end

  context "when sending POST request" do
    it "forwards request to the API backend with HTTP protocol" do
      api.should_receive(
                         :post
                         ).with(
                                match(url_matcher),
                                hash_including(params)
                                ).and_return(response)

      expect(facade.post("/test", params)).to be response
    end
  end

  context "when GETting raw resource contents" do
    it "forwards request to the API backend with HTTP protocol" do
      api.should_receive(
                         :raw
                         ).with(
                                match(url_matcher),
                                hash_including(params)
                                ).and_return(response)

      expect(facade.raw("/test", params)).to be response
    end
  end

  context "when generating web link" do
    it "forwards request to the API backend with HTTP protocol" do
      api.should_receive(
                         :web
                         ).with(
                                match(url_matcher),
                                hash_including(params)
                                ).and_return(response)

      expect(facade.web("/test", params)).to be response
    end
  end

  context "when loading a list of folders" do
    it "wraps own 'get' method" do
      account_id = 99

      facade.should_receive(
                            :get
                            ).with(
                                   "/accounts/#{account_id}/folders.xml",
                                   { :action => "get"}
                                   ).and_return(response)

      expect(facade.get_folders(account_id)).to be response
    end
  end
end

describe Gliffy::API::Facade do
  let(:api) { double(Gliffy::API) }
  let(:response) { double(Gliffy::API::Response) }
  let(:params) {
    {
      :test1 => "value1",
      :test2 => "value2"
    }
  }

  describe "plain facade" do
    let(:facade) { Gliffy::API::Facade.http(api) }

    it_should_behave_like "an API facade" do
      let(:url_matcher) { %{http://.+/test} }
    end
  end

  describe "secure facade" do
    let(:facade) { Gliffy::API::Facade.https(api) }

    it_should_behave_like "an API facade" do
      let(:url_matcher) { %{https://.+/test} }
    end
  end

  describe "static methods" do
    subject { Gliffy::API::Facade }

    it "provide access to API via basic HTTP protocol" do
      expect(subject).to respond_to :http
      expect(subject.http(api)).to be_instance_of Gliffy::API::Facade
    end

    it "provide access to API via secure HTTPS protocol" do
      expect(subject).to respond_to :https
      expect(subject.https(api)).to be_instance_of Gliffy::API::Facade
    end
  end
end
