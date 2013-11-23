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

  it "has a list of users" do
    api
      .stub(:get_users)
      .and_return(Gliffy::API::Response.new(fixture("user-list")))

    expect(account).to respond_to :users
    expect(account.users).to be_instance_of Array
    expect(account.users.length).to eq 4

    account.users.each do |u|
      expect(u).to be_instance_of Gliffy::User
    end
  end

  it "delegates the task of fetching user list to API" do
    api
      .stub(:get_users)
      .and_return(Gliffy::API::Response.new(fixture("user-list")))

    account.users

    expect(api).to have_received(:get_users)
      .with(account_id)
  end

  it "allows to create a new user" do
    expect(account).to respond_to :create_user
  end

  context "when creating new user" do
    let(:username) { "USER" }
    let(:user1) { double(Gliffy::User, :username => "A") }
    let(:user2) { double(Gliffy::User, :username => "B") }
    let(:user) { double(Gliffy::User, :username => username) }

    before :each do
      api.stub(:create_user)

      account.stub(:users)
        .and_return([user1, user2],
                    [user1, user, user2])
    end

    it "calls REST API" do
      account.create_user username

      expect(api).to have_received(:create_user)
        .with(username)
    end

    it "returns this user" do
      new_user = account.create_user username
      expect(new_user).to be user
    end

    context "when username contains a space" do
      let(:username) { "US ER" }

      it "throws an exception" do
        expect { account.create_user username }.to raise_error
      end
    end

    context "when username is already taken" do
      let(:username) { "USER" }
      let(:user) { double(Gliffy::User, { :username => username }) }

      before :each do
        account.stub(:users).and_return([user])
      end

      it "throws an exception" do
        expect { account.create_user username }.to raise_error
      end
    end
  end

end
