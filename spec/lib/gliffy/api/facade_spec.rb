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

  context "when updating document metadata" do
    let(:document_id) { 221 }
    let(:document_name) { "NEW DOCUMENT" }
    let(:public_flag) { true }
    let(:public_text) { "true" }

    it "sends POST request" do
      facade
        .should_receive(:post)
        .with("/accounts/#{account_id}/documents/#{document_id}/meta-data.xml",
              hash_including(:action => "update",
                             :documentName => document_name,
                             :public => public_text))

      facade.update_document_metadata(document_id, document_name, public_flag)
    end

    it "doesn't send name if no name is passed to the method" do
      facade
        .should_receive(:post)
        .with(anything(),
              hash_not_including(:documentName))

      facade.update_document_metadata(document_id, nil, public_flag)
    end

    it "doesn't send public flag if it is not passed to the method" do
      facade
        .should_receive(:post)
        .with(anything(),
              hash_not_including(:public))

      facade.update_document_metadata(document_id, document_name, nil)
    end
  end

  it "allows user to delete a document" do
    expect(facade).to respond_to :delete_document
  end

  context "when deleting a document" do
    let(:document_id) { 221 }

    it "sends POST request" do
      facade
        .should_receive(:post)
        .with("/accounts/#{account_id}/documents/#{document_id}.xml",
              hash_including(:action => "delete"))

      facade.delete_document(document_id)
    end
  end
end

describe Gliffy::API::Facade do
  let(:account_id) { 99 }
  let(:api) { double(Gliffy::API, { :account_id => account_id }) }
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
