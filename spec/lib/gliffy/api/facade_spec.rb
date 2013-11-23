require 'spec_helper'

shared_examples_for "an API facade" do
  it "has folder path escame method" do
    expect(facade).to respond_to :escape_path
  end

  describe "folder path escape method" do
    it "escapes spaces" do
      expect(facade.escape_path("A B")).to eq "A+B"
    end

    it "does not escape slashes" do
      expect(facade.escape_path("A/B")).to eq "A/B"
    end
  end

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

  it "allows user to move document to a different folder" do
    expect(facade).to respond_to :move_document
  end

  context "when moving a document" do
    let(:document_id) { 144 }
    let(:folder_path) { "ROOT/FOLDER/SUBFOLDER" }

    before :each do
      facade.stub(:post)
    end

    it "sends POST request" do
      facade.move_document(document_id, folder_path)

      expect(facade).to have_received(:post)
        .with("/accounts/#{account_id}/folders/#{folder_path}/documents/#{document_id}.xml",
              hash_including(:action => "move"))
    end
  end

  it "allows to load documents in a folder" do
    expect(facade).to respond_to :get_documents_in_folder
  end

  context "when loading documents in a folder" do
    let(:folder_path) { "ROOT/test" }
    let(:response) { double(Gliffy::API::Response) }

    before :each do
      facade.stub(:get).and_return(response)
      facade.stub(:escape_path).and_call_original

      facade.get_documents_in_folder(folder_path)
    end

    it "sends GET request" do
      expect(facade).to have_received(:get)
        .with("/accounts/#{account_id}/folders/ROOT/test/documents.xml",
              hash_including(:action => "get"))
    end

    it "escapes folder path properly" do
      expect(facade).to have_received(:escape_path)
        .with(folder_path)
    end
  end

  it "allows user to delete a folder" do
    expect(facade).to respond_to :delete_folder
  end

  context "when deleting a folder" do
    let(:folder_path) { "ROOT/test" }

    before :each do
      facade.stub(:post)
      facade.stub(:escape_path).and_call_original

      facade.delete_folder(folder_path)
    end

    it "escapes folder path properly" do
      expect(facade).to have_received(:escape_path)
        .with(folder_path)
    end

    it "sends POST request" do
      expect(facade).to have_received(:post)
        .with("/accounts/#{account_id}/folders/#{folder_path}.xml",
              hash_including(:action => "delete"))
    end
  end

  it "allows user to create a document" do
    expect(facade).to respond_to :create_document
  end

  context "when creating a document" do
    let(:document_name) { "NAME" }
    let(:document_type) { Gliffy::Document::TYPE_DIAGRAM }
    let(:original_id) { 45 }
    let(:path) { "ROOT/FOLDER" }

    it "sends POST request" do
      facade.should_receive(:post)
        .with("/accounts/#{account_id}/documents.xml",
              hash_including(:action => "create",
                             :documentName => document_name,
                             :documentType => document_type,
                             :templateDiagramId => original_id,
                             :folderPath => path))

      facade.create_document(document_name, document_type, original_id, path)
    end

    context "when template id is not provided" do
      it "doesn't send template id" do
        facade.should_receive(:post)
          .with(anything(),
                hash_not_including(:templateDiagramId))

        facade.create_document(document_name, document_type, nil, path)
      end
    end

    context "when path is not provided" do
      it "doesn't send path" do
        facade.should_receive(:post)
          .with(anything(),
                hash_not_including(:folderPath))

        facade.create_document(document_name, document_type, original_id, nil)
      end
    end
  end

  it "allows user to create a folder" do
    expect(facade).to respond_to :create_folder
  end

  context "when creating a folder" do
    let(:folder_path) { "ROOT/TEST/SUBFOLDER" }

    it "sends POST request" do
      facade.stub(:post)

      facade.create_folder(folder_path)

      expect(facade).to have_received(:post)
        .with("/accounts/#{account_id}/folders/#{folder_path}.xml",
              hash_including(:action => "create"))
    end
  end

  it "has provides access to folder list" do
    expect(facade).to respond_to :get_users
  end

  context "when loading user list" do
    let(:response) { double(Gliffy::API::Response) }

    it "sends GET request and returns its result" do
      facade.stub(:get).and_return(response)

      expect(facade.get_users(account_id)).to be response

      expect(facade).to have_received(:get)
        .with("/accounts/#{account_id}/users.xml",
              hash_including(:action => "get"))
    end
  end

  it "allows to create a new user" do
    expect(facade).to respond_to :create_user
  end

  context "when creating user" do
    let(:username) { "USER" }
    let(:email) { "test@test.com" }

    before :each do
      facade.stub(:post)
    end

    it "sends POST request to API" do
      facade.create_user username

      expect(facade).to have_received(:post)
        .with("/accounts/#{account_id}/users.xml",
              hash_including(:action => "create" ))
    end
  end

  it "allows to delete existing user" do
    expect(facade).to respond_to :delete_user
  end

  context "when deleting user" do
    let(:username) { "USER" }

    before :each do
      facade.stub(:post)
    end

    it "sends POST request to API" do
      facade.delete_user username

      expect(facade).to have_received(:post)
        .with("/accounts/#{account_id}/users/#{username}.xml",
              hash_including(:action => "delete"))
    end
  end

  context "when POST request returns an error" do
    let(:response) { Gliffy::API::Response.new(fixture("error-401")) }

    before :each do
      api.stub(
        :post
      ).and_return(
        response
      )
    end

    it "throws an exception" do
      expect { facade.post("/random_url", {}) }.to raise_error(Gliffy::API::Error)
    end
  end

  context "when GET request returns an error" do
    let(:response) { Gliffy::API::Response.new(fixture("error-401")) }

    before :each do
      api.stub(
        :get
      ).and_return(
        response
      )
    end

    it "throws an exception" do
      expect { facade.get("/random_url", {}) }.to raise_error(Gliffy::API::Error)
    end
  end
end

describe Gliffy::API::Facade do
  let(:account_id) { 99 }
  let(:api) { double(Gliffy::API, { :account_id => account_id }) }
  let(:response) { double(Gliffy::API::Response, :error? => false) }
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
