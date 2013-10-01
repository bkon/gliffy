# -*- coding: utf-8-unix -*-
require 'spec_helper'

describe Gliffy::Folder do
  let(:account_id) { 100 }
  let(:api) { double(Gliffy::API) }
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

  describe "root folder" do
    it "knows it is root" do
      expect(folder.root?).to be_true
    end

    it "has no parent" do
      expect(folder.parent).to be_nil
    end
  end

  describe "document list" do
    it "is loaded from API" do
      api.should_receive(
        :get
      ).and_return(
        Gliffy::API::Response.new(fixture("documents"))
      )

      folder.documents
    end

    it "has correct length" do
      api.stub(
        :get
      ).and_return(
        Gliffy::API::Response.new(fixture("documents"))
      )

      expect(folder.documents.length).to eq 3
    end

    it "is empty when API returns appropriate response" do
      api.stub(
        :get
      ).and_return(
        Gliffy::API::Response.new(fixture("documents-empty"))
      )

      expect(folder.documents.length).to eq 0
    end
  end

  it "has nested folders" do
    expect(folder).to respond_to :folders
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
end
