require 'spec_helper'

describe Gliffy::Document do
  before :each do
    Gliffy::Document.clear_cache
  end

  let(:api)  { double(Gliffy::API::Facade) }
  let(:owner) do
    owner = double(Gliffy::Account)
    owner.stub(:api).and_return(api)
    owner
  end

  let(:document_id) { 1000002 }
  let(:document_name) { 'SNPP Domain Model' }

  let(:response) do
    Gliffy::API::Response.new(fixture(
      "document",
      :document_id => document_id,
      :document_name => document_name
      )
    )
  end

  let(:document) do
    Gliffy::Document.load(owner, response.node("//g:document"))
  end

  it "has an id" do
    expect(document).to respond_to :id
    expect(document.id).to eq document_id
  end

  it "has a name" do
    expect(document).to respond_to :name
    expect(document.name).to eq document_name
  end

  it "has 'public access' flag" do
    expect(document).to respond_to :public?
    expect(document.public?).to eq(true)
  end

  it "has a version number" do
    expect(document).to respond_to :versions
    expect(document.versions).to eq(5)
  end

  it "has a modification date" do
    expect(document).to respond_to :modified
    expect(document.modified).to eq(DateTime.new(2008, 7, 8, 17, 31, 23))
  end

  it "has a creation date" do
    expect(document).to respond_to :created
    expect(document.created).to eq(DateTime.new(2008, 7, 8, 17, 31, 24))
  end

  it "has a publication date" do
    expect(document).to respond_to :published
    expect(document.published).to eq(DateTime.new(2008, 7, 8, 17, 31, 25))
  end

  it "has an owner" do
    expect(document).to respond_to :owner
    expect(document.owner).to be(owner)
  end

  it "has a link to gliffy editor" do
    return_url = "sample/url"
    return_text = "RETURN TEXT"

    api.should_receive(
      :web
    ).with(
      "/gliffy/",
      hash_including(
        :launchDiagramId => document_id,
        :returnURL => return_url,
        :returnButtonText => return_text
      )
    ).and_return(
      "http://www.gliffy.com/gliffy/?launchDiagramId=#{document.id}&returnURL=#{return_url}&returnButtonText=#{return_text}"
    )

    link = document.editor(return_url, return_text)

    expect(link).to match '/gliffy/'
    expect(link).to match 'launchDiagramId='
    expect(link).to match document.id.to_s
    expect(link).to match 'returnURL='
    expect(link).to match return_url
    expect(link).to match 'returnButtonText='
    expect(link).to match return_text
  end

  it "has an PNG image" do
    expect(document).to respond_to :png
    expect(document.png).to be_instance_of Gliffy::Document::Presentation::PNG
  end

  it "has SVG representation" do
    expect(document).to respond_to :svg
    expect(document.svg).to be_instance_of Gliffy::Document::Presentation::SVG
  end

  it "has XML representation" do
    expect(document).to respond_to :xml
    expect(document.xml).to be_instance_of Gliffy::Document::Presentation::XML
  end

  it "has singleton-life behavior" do
    doc1 = Gliffy::Document.load(owner, response.node("//g:document"))
    expect(doc1).to be document
  end

  it "can be renamed" do
    expect(document).to respond_to :rename
  end

  context "when renamed" do
    let(:new_name) { "NEW DOCUMENT NAME" }
    before :each do
      api.stub(:update_document_metadata)
      document.rename new_name
    end

    it "changes the name to the new value" do
      expect(document.name).to eq new_name
    end

    it "calls rename method of the REST API" do
      expect(api).to have_received(:update_document_metadata)
        .with(document_id, new_name, nil)
    end
  end

  it "can be made public or private" do
    expect(document).to respond_to :public=
  end

  context "when public state changes" do
    let(:new_shared) { false }

    before :each do
      api.stub(:update_document_metadata)

      document.public = new_shared
    end

    it "calls REST API" do
      expect(api).to have_received(:update_document_metadata)
        .with(document_id, nil, new_shared)
    end

    it "updates local object" do
      expect(document.public?).to eq new_shared
    end
  end

  it "can be moved" do
    expect(document).to respond_to :move
  end

  context "when moved" do
    let(:observer) { double(Object, :update => nil) }
    let(:folder) do
      double(Gliffy::Folder,
             :path => "ROOT/FOLDER/SUBFOLDER",
             :update => nil)
    end

    before :each do
      api.stub(:move_document)

      document.add_observer(observer)
      document.move(folder)
    end

    it "calls REST API" do
      expect(api).to have_received(:move_document)
        .with(document.id, folder.path)
    end

    it "notifies observers" do
      expect(observer).to have_received(:update)
        .with(:document_removed, document)
    end

    it "notifies new parent" do
      expect(folder).to have_received(:update)
        .with(:document_added, document)
    end
  end

  it "can be deleted" do
    expect(document).to respond_to :delete
  end

  it "has flag indicating whether this object has been deleted" do
    expect(document).to respond_to :deleted?
  end

  context "when not deleted" do
    it "knows it" do
      expect(document.deleted?).to be_false
    end
  end

  context "when deleted" do
    let(:observer) { double(Object) }

    before :each do
      api.stub(:delete_document)

      observer.stub(:update)
      document.add_observer(observer)

      document.delete
    end

    it "calls REST API" do
      expect(api).to have_received(:delete_document)
        .with(document_id)
    end

    it "knows it" do
      expect(document.deleted?).to be_true
    end

    it "notifies observers" do
      expect(observer).to have_received(:update).with(:document_deleted, document)
    end
  end
end
