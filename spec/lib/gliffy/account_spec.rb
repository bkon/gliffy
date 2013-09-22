require 'spec_helper'

describe Gliffy::Account do
  let(:account_id) { 101 }
  let(:expiration) { 32154788584000 }
  let(:api) do
    api = double(Gliffy::API)
    api.stub(
      :get_folders
    ).and_return(
      Gliffy::API::Response.new(fixture("folder"))
    )
    api
  end

  let(:account) do
    response = Gliffy::API::Response.new(
      fixture(
        "account",
        :account_id => account_id,
        :expiration => expiration
        )
      )
    Gliffy::Account.load(api, response)
  end

  it "has an id" do
    expect(account).to respond_to :id
    expect(account.id).to eq account_id
  end

  it "has a name" do
    expect(account).to respond_to :name
    expect(account.name).to eq "BurnsODyne"
  end

  it "has max users count" do
    expect(account).to respond_to :max_users
    expect(account.max_users).to eq 10
  end

  it "has a type" do
    expect(account).to respond_to :type
    expect(account.type).to eq Gliffy::Account::TYPE_BUSINESS
  end

  it "has 'terms accepted' flag" do
    expect(account).to respond_to :terms_accepted
    expect(account.terms_accepted).to be_true
  end

  it "has an expiration date" do
    expect(account).to respond_to :expiration_date
    expect(account.expiration_date).to eq Time.at(expiration / 1000).to_datetime
  end

  it "provides direct access to documents" do
    expect(account).to respond_to :document
  end

  it "delegates task of fetching the document to API" do
    document_id = 1011
    document_name = "NAME"

    document_fixture = fixture(
      "document",
      :document_id => document_id,
      :document_name => document_name
    )

    api.should_receive(
      :get
    ).with(
      "/accounts/#{account_id}/documents/#{document_id}/meta-data.xml",
      hash_including(
        :action => 'get'
      )
    ).and_return(Gliffy::API::Response.new(document_fixture))

    document = account.document(document_id)

    expect(document.id).to eq document_id
    expect(document.name).to eq document_name
    expect(document.owner).to be account
  end

  it "has a root folder" do
    expect(account).to respond_to :root
    expect(account.root).to be_instance_of Gliffy::Folder
  end

  describe "root folder" do
    subject(:root_folder) { account.root }

    it "is named ROOT" do
      expect(root_folder.name).to eq "ROOT" 
    end

    it "has ROOT path" do
      expect(root_folder.path).to eq "ROOT"
    end

    it "refers to the original account as owner" do
      expect(root_folder.owner).to be account
    end
  end
end
