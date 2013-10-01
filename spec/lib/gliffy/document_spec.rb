require 'spec_helper'

describe Gliffy::Document do
  before :each do
    Gliffy::Document.clear_cache
  end

  let(:api)  { double(Gliffy::API) }
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
    expect(document.png).to be_instance_of Gliffy::Document::PNG
  end

  it "has SVG representation" do
    expect(document).to respond_to :svg
    expect(document.svg).to be_instance_of Gliffy::Document::SVG
  end

  it "has singleton-life behavior" do
    doc1 = Gliffy::Document.load(owner, response.node("//g:document"))
    expect(doc1).to be document
  end
end
