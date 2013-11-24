# -*- coding: utf-8-unix -*-
require 'spec_helper'

describe Gliffy::Folder do
  let(:account_id) { 100 }
  let(:api) { double(Gliffy::API::Facade) }
  let(:account) { double(Gliffy::Account, :api => api, :id => account_id) }

  subject(:folder) do
    Gliffy::Folder.load(
      account,
      Gliffy::API::Response.new(
        fixture('folder')
      ).node("//g:folders/g:folder[1]")
    )
  end

  it "has a name" do
    expect(folder).to respond_to :name
    expect(folder.name).to eq "ROOT"
  end

  it "has a path" do
    expect(folder).to respond_to :path
    expect(folder.path).to eq "ROOT"
  end

  it "has a list of documents" do
    expect(folder).to respond_to :documents
  end

  it "has a list of users with access to this folder" do
    expect(folder).to respond_to :users
  end

  describe "user list" do
    before :each do
      api.stub(:users_with_access_to_folder)
        .and_return(Gliffy::API::Response.new(fixture("folder-users")))
    end

    subject(:users) { folder.users }

    it "is an array" do
      expect(users).to be_instance_of Array
    end

    it "has correct length" do
      expect(users.length).to eq 4
    end

    it "contains correct user objects" do
      expect(users[0].username).to eq "barney"
      expect(users[3].username).to eq "homer"
    end
  end

  describe "root folder" do
    it "knows it is root" do
      expect(folder.root?).to be_true
    end

    it "has no parent" do
      expect(folder.parent).to be_nil
    end
  end

  describe "document list" do
    let(:response) { Gliffy::API::Response.new(fixture("documents")) }

    before :each do
      api.stub(:get_documents_in_folder)
        .and_return(response)
    end

    it "is loaded from API" do
      folder.documents

      expect(api).to have_received(:get_documents_in_folder)
        .with(folder.path)
    end

    it "has correct length" do
      expect(folder.documents.length).to eq 3
    end

    context "when API returns empty response" do
      let(:response) { Gliffy::API::Response.new(fixture("documents-empty")) }

      it "is empty" do
        expect(folder.documents.length).to eq 0
      end
    end
  end

  it "has nested folders" do
    expect(folder).to respond_to :folders
  end

  it "listens for changes in nested folders" do
    folder.stub(:update)

    folder.folders[0].changed
    folder.folders[0].notify_observers(:event, :target)

    expect(folder).to have_received(:update)
      .with(:event, :target)
  end

  describe "folder list" do
    subject(:children) { folder.folders }

    it { should respond_to :length }
    it { should respond_to :[] }
    it "has corrent length" do
      expect(children.length).to eq 4
    end
  end

  describe "first-level folder 'Burns Top Secret'" do
    subject(:first_child) { folder.folders[0] }

    it "has correct parent" do
      expect(first_child.parent).to be folder
    end

    it "has correct name" do
      expect(first_child.name).to eq "Burns Top Secret"
    end

    it "has correct path" do
      expect(first_child.path).to eq "ROOT/Burns Top Secret"
    end

    it "has correct number of children" do
      expect(first_child.folders).to eq []
    end

    it "knows it is not root" do
      expect(first_child.root?).to be_false
    end
  end

  describe "first-level folder 'Simsons Family'" do
    subject(:second_child) { folder.folders[3] }

    it "has correct parent" do
      expect(second_child.parent).to be folder
    end

    it "has correct name" do
      expect(second_child.name).to eq "Simpsons Family"
    end

    it "has correct path" do
      expect(second_child.path).to eq "ROOT/Simpsons Family"
    end

    it "has corrent number of children" do
      expect(second_child.folders.length).to eq 2
    end

    it "knows it is not root" do
      expect(second_child.root?).to be_false
    end

    describe "second-level folder 'Maggie and Lisas Stuff'" do
      subject(:nested_child) { second_child.folders[1] }

      it "has corrent parent" do
        expect(nested_child.parent).to be second_child
      end

      it "has correct name" do
        expect(nested_child.name).to eq "Maggie and Lisas Stuff"
      end

      it "has correct path" do
        expect(nested_child.path).to eq "ROOT/Simpsons Family/Maggie and Lisas Stuff"
      end

      it "knows it is not root" do
        expect(nested_child.root?).to be_false
      end
    end
  end

  context "when assigning a parent" do
    context "with valid path" do
      it "updates parent" do
        f1 = Gliffy::Folder.new(account, "F1", "/ROOT/F1", [])
        f2 = Gliffy::Folder.new(account, "F2", "/ROOT/F1/F2", [])

        f2.parent = f1
        expect(f2.parent).to be f1
      end
    end

    context "with invalid path" do
      it "raises an error" do
        f1 = Gliffy::Folder.new(@account, "F1", "/ROOT/F1", [])
        f2 = Gliffy::Folder.new(@account, "F2", "/ROOT/F2", [])
        expect { f1.parent = f2 }.to raise_error
      end
    end
  end

  it "allows us to create a document" do
    expect(folder).to respond_to :create_document
  end

  context "when creating a document" do
    let(:document_name) { "NEW DOCUMENT NAME" }

    before :each do
      api.stub(:create_document)
      folder.create_document(document_name)
    end

    it "calls REST API" do
      expect(api).to have_received(:create_document)
        .with(document_name,
              Gliffy::Document::TYPE_DIAGRAM,
              nil,
              folder.path)
    end
  end

  it "allows us to create a folder" do
    expect(folder).to respond_to :create_folder
  end

  context "when creating a folder" do
    let(:folder_name) { "SUBFOLDER" }

    before :each do
      api.stub(:create_folder)
    end

    it "calls REST API" do
      folder.create_folder(folder_name)
      expect(api).to have_received(:create_folder)
        .with(folder.path + "/" + folder_name)
    end

    it "returns new folder" do
      new_folder = folder.create_folder(folder_name)
      expect(new_folder).to be_instance_of Gliffy::Folder
    end

    it "updates subfolder list" do
      old_length = folder.folders.length

      new_folder = folder.create_folder(folder_name)

      expect(folder.folders.length).to eq old_length + 1
      expect(folder.folders).to include new_folder
    end

    context "when subfolder with the same name already exists" do
      let(:folder_name) { folder.folders[0].name }

      it "throws an exception" do
        expect { folder.create_folder(folder_name) }.to raise_error ArgumentError
      end
    end

    context "when subfolder with differently capitalized name already exists" do
      let(:folder_name) { folder.folders[0].name.swapcase }

      it "throws an exception" do
        expect { folder.create_folder(folder_name) }.to raise_error ArgumentError
      end
    end
  end

  context "when notified that a document has been removed" do
    let(:document) do
      api.stub(:get_documents_in_folder)
        .and_return(Gliffy::API::Response.new(fixture("documents")))

      folder.documents[1]
    end

    before :each do
      document.stub(:delete_observer).and_call_original
    end

    it "removes document from the document list" do
      original_length = folder.documents.length

      folder.update(:document_removed, document)

      expect(folder.documents.length).to eq original_length - 1
      expect(folder.documents).to_not include document
    end

    it "stops listening to this document's events" do
      folder.update(:document_removed, document)

      expect(document).to have_received(:delete_observer)
        .with(folder)
    end
  end

  context "when notified that a document has been added" do
    let(:document) do
      api.stub(:get_documents_in_folder)
        .and_return(Gliffy::API::Response.new(fixture("documents")))

      folder.documents[1]
    end

    before :each do
      document.stub(:add_observer).and_call_original
    end

    it "adds document to the document list" do
      original_length = folder.documents.length

      folder.update(:document_added, document)

      expect(folder.documents.length).to eq original_length + 1
      expect(folder.documents).to include document
    end

    it "starts listening to this document's events" do
      folder.update(:document_added, document)

      expect(document).to have_received(:add_observer)
        .with(folder)
    end
  end

  context "when receives a document delete notification" do
    let(:document) do
      api.stub(:get_documents_in_folder)
        .and_return(Gliffy::API::Response.new(fixture("documents")))

      folder.documents[1]
    end

    before :each do
      document.stub(:delete_observer).and_call_original
    end

    it "removes document from the document list" do
      original_length = folder.documents.length

      folder.update(:document_deleted, document)

      expect(folder.documents.length).to eq original_length - 1
      expect(folder.documents).to_not include document
    end

    it "stops listening to this document's events" do
      folder.update(:document_deleted, document)

      expect(document).to have_received(:delete_observer)
        .with(folder)
    end
  end

  context "when received a child folder delete notification" do
    it "removes folder from the children list" do
      original_length = folder.folders.length
      child = folder.folders[1]

      folder.update(:folder_deleted, child)

      expect(folder.folders.length).to eq original_length - 1
      expect(folder.folders).to_not include child
    end
  end

  context "when receives an unknown event" do
    let(:document) { double(Gliffy::Document) }

    it "throws an exception" do
      expect { folder.update(:unknown, document) }.to raise_error ArgumentError
    end
  end

  it "can be deleted" do
    expect(folder).to respond_to :delete
  end

  it "knows its deleted state" do
    expect(folder).to respond_to :deleted?
  end

  it "is not marked as deleted by default" do
    expect(folder.deleted?).to be_false
  end

  context "when being deleted" do
    let(:observer) { double(Object) }

    before :each do
      api.stub(:delete_folder)

      observer.stub(:update)
      folder.add_observer(observer)

      folder.delete
    end

    it "calls REST API" do
      expect(api).to have_received(:delete_folder)
        .with(folder.path)
    end

    it "notifies observers about this" do
      expect(observer).to have_received(:update).with(:folder_deleted, folder)
    end

    it "is marked as deleted" do
      expect(folder.deleted?).to be_true
    end
  end

  describe "access rights" do
    let(:username) { "USERNAME" }
    let(:user) { double(Gliffy::User, :username => username ) }

    it "can be granted" do
      expect(folder).to respond_to :grant_access
    end

    context "when granting" do
      before :each do
        api.stub(:grant_access_to_folder)
        folder.grant_access(user)
      end

      it "calls API" do
        expect(api).to have_received(:grant_access_to_folder)
          .with(username, folder.path)
      end
    end

    it "can be revoked" do
      expect(folder).to respond_to :revoke_access
    end

    context "when revoking" do
      before :each do
        api.stub(:revoke_access_to_folder)
        folder.revoke_access(user)
      end

      it "calls API" do
        expect(api).to have_received(:revoke_access_to_folder)
          .with(username, folder.path)
      end
    end
  end
end
